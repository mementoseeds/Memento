##    This file is part of Memento.
 #
 #    Memento is free software: you can redistribute it and/or modify
 #    it under the terms of the GNU General Public License as published by
 #    the Free Software Foundation, either version 3 of the License, or
 #    (at your option) any later version.
 #
 #    Memento is distributed in the hope that it will be useful,
 #    but WITHOUT ANY WARRANTY; without even the implied warranty of
 #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #    GNU General Public License for more details.
 #
 #    You should have received a copy of the GNU General Public License
 #    along with Memento.  If not, see <https://www.gnu.org/licenses/>.
 ##

import os
from os.path import join
import re
import json
import requests
from bs4 import BeautifulSoup

class MemriseCourse():
    def __init__(self, url):
        # Setup
        print("Gathering preliminary data")
        self.level = []
        self.itemCount = 0

        url = url if not url.endswith("/") else url[0:-1]
        courseId = url.split("/")[-2]
        soup = BeautifulSoup(requests.get(url).content, features="lxml")

        # Course title and creator
        print("Scraping course title and creator")
        top = soup.head.title.string.strip().split(" - ")
        self.title = top[0].strip().replace("/", "∕")
        self.creator = re.sub("^by ", "", top[1].strip())
        del top

        # Course category
        print("Scraping course category")
        self.category = soup.find("div", class_ = "course-breadcrumb").find_all("a")[-1].string.strip()

        # Course icon
        print("Scraping course icon")
        self.iconUrl = soup.find("a", class_ = "course-photo").find_next("img")["src"]

        # Course description
        print("Scraping course description")
        self.description = soup.find("span", class_ = "course-description").string.strip()

        # Course total levels
        print("Scraping level count")
        lastLevelUrl = soup.find_all("a", class_ = "level")[-1]["href"]
        self.levelAmount = int(lastLevelUrl.split("/")[-2 if lastLevelUrl.endswith("/") else -1])
        del lastLevelUrl

        # Level urls
        print("Building level URLs")
        self.levelUrls = [url + "/" + str(i) for i in range(1, self.levelAmount + 1)]
        
        # Pool ID
        print("Finding pool ID")
            
        randomThingId = None
        for i in self.levelUrls:
            soup = BeautifulSoup(requests.get(i).content, features="lxml")
            thing = soup.find("div", class_ = "thing text-text")
            if thing:
                randomThingId = thing["data-thing-id"]
                break
        if randomThingId == None:
            exit("Is this a media only level?")

        poolId = requests.get("https://app.memrise.com/api/thing/get/?thing_id=" + randomThingId).json()["thing"]["pool_id"]
        self.pool = requests.get("https://app.memrise.com/api/pool/get/?pool_id=" + str(poolId)).json()

    def scrapeLevels(self, start, stop):
        print()

        for i in range(max(0, start - 1), min(self.levelAmount, stop)):
            soup = BeautifulSoup(requests.get(self.levelUrls[i]).content, features="lxml")
            levelContent = {}

            levelContent["title"] = soup.find("h3", class_ = "progress-box-title").text.strip()
            print("Scraping level", levelContent["title"])

            # Skip grammar levels in official Memrise courses
            if soup.find("div", class_ = "grammar-not-available"):
                print("Skipping grammar level", levelContent["title"])
                continue
            
            # Handle separately if the level is multimedia
            thing = soup.find("div", class_ = "thing text-text")
            if not thing:
                levelContent["isMultimedia"] = True
                
                pattern = re.compile("var level_multimedia = '(.*?)';$", re.MULTILINE)
                rawMedia = soup.find("script", text = pattern).string.strip()
                cleanMedia = re.sub("^var level_multimedia = '|';$", "", rawMedia)
                
                levelContent["mediaContent"] = cleanMedia.encode("utf-8").decode('unicode-escape')
                self.level.append(levelContent)

                continue
                
            # Handle if it is a normal level
            levelContent["isMultimedia"] = False

            # Gather item IDs in level
            levelContent["items"] = [div["data-thing-id"] for div in soup.find_all("div", class_ = "thing text-text")]
            self.itemCount += len(levelContent["items"])

            # Get level columns
            columnData = soup.find("div", class_ = "things clearfix")
            levelContent["testColumn"] = columnData["data-column-a"]
            levelContent["promptColumn"] = columnData["data-column-b"]
            del columnData

            self.level.append(levelContent)
    
    def writeCourseInfo(self, destination):
        self.courseDir = join(destination, self.title)
        
        try:
            os.mkdir(self.courseDir)
            
            print("mkdir", self.courseDir)

            os.mkdir(join(self.courseDir, "levels"))
            os.mkdir(join(self.courseDir, "assets"))
            os.mkdir(join(self.courseDir, "assets", "audio"))
            os.mkdir(join(self.courseDir, "assets", "images"))
        except FileExistsError as e:
            print(str(e))
            print("Remove conflicting files and try again")
            exit()

        # Write icon file
        print("Downloading icon")

        iconFile = join(self.courseDir, "assets", "images", "icon.jpg")
        open(iconFile, "wb").write(requests.get(self.iconUrl).content)

        # Create dictionary
        print("Creating info.json")

        courseInfo = {"title": self.title,
            "author": self.creator,
            "description": self.description,
            "category": self.category,
            "icon": "assets/images/icon.jpg",
            "items": self.itemCount,
            "planted": 0,
            "water": 0,
            "difficult": 0,
            "ignored": 0,
            "completed": False}
        
        # Write course info json
        json.dump(courseInfo, open(join(self.courseDir, "info.json"), "w"), indent = 4, ensure_ascii = False)

    
    def buildSeedbox(self, skipAudio):
        print("Finding unique items across all levels")

        self.seedbox = {}
        uniqueItems = []
        for lvl in self.level:
            if not lvl["isMultimedia"]:
                for item in lvl["items"]:
                    if not item in uniqueItems:
                        uniqueItems.append(item)

        print("Finding item information from API")

        counter = 1
        totalUniqueItems = len(uniqueItems)
        for item in uniqueItems:
            print("Scraping item", counter, "of", totalUniqueItems)
            counter += 1

            itemInfo = requests.get("https://app.memrise.com/api/thing/get/?thing_id=" + item).json()
            key = str(item)

            self.seedbox[key] = {}
            self.seedbox[key]["attributes"] = itemInfo["thing"]["attributes"]["1"]["val"] if "1" in itemInfo["thing"]["attributes"] else ""
            self.seedbox[key]["audio"] = []

            # Columns
            for column in itemInfo["thing"]["columns"]:
                if itemInfo["thing"]["columns"][column]["kind"] == "audio" and not skipAudio:
                    for audio in itemInfo["thing"]["columns"][column]["val"]:
                        audioName = audio["url"].split("/")[-1]
                        open(join(self.courseDir, "assets", "audio", audioName), "wb").write(requests.get(audio["url"]).content)
                        self.seedbox[key]["audio"].append("assets/audio/" + audioName)
                
                elif itemInfo["thing"]["columns"][column]["kind"] == "text":
                    self.seedbox[key][self.pool["pool"]["columns"][column]["label"]] = {}
                    
                    self.seedbox[key][self.pool["pool"]["columns"][column]["label"]]["primary"] = itemInfo["thing"]["columns"][column]["val"]
                    
                    self.seedbox[key][self.pool["pool"]["columns"][column]["label"]]["image"] = ""

                    self.seedbox[key][self.pool["pool"]["columns"][column]["label"]]["alternative"] = [alt["val"] for alt in itemInfo["thing"]["columns"][column]["alts"]] if len(itemInfo["thing"]["columns"][column]["alts"]) > 0 else []

    def writeSeedbox(self):
        print("Writing seedbox.json")
        json.dump(self.seedbox, open(join(self.courseDir, "seedbox.json"), "w"), indent = 4, ensure_ascii = False)

    def createLevels(self):
        print("Creating level files")
        
        for i in range(0, len(self.level)):
            if self.level[i]["isMultimedia"]:
                levelFile = open(join(self.courseDir, "levels", str(i + 1) + ".md"), "w")
                levelFile.write("[comment]: <> (" + self.level[i]["title"] + ")\n")
                levelFile.write(self.level[i]["mediaContent"])
                levelFile.close()
            
            else:
                levelFile = open(join(self.courseDir, "levels", str(i + 1) + ".json"), "w")
                levelInfo = {"title": self.level[i]["title"],
                    "completed": False,
                    "test": self.pool["pool"]["columns"][self.level[i]["testColumn"]]["label"],
                    "prompt": self.pool["pool"]["columns"][self.level[i]["promptColumn"]]["label"]}

                seeds = {}
                for item in self.level[i]["items"]:
                    seeds[item] = {}
                    seeds[item]["planted"] = False
                    seeds[item]["nextWatering"] = ""
                    seeds[item]["ignored"] = False
                    seeds[item]["difficult"] = False
                    seeds[item]["successes"] = 0
                    seeds[item]["failures"] = 0
                    seeds[item]["streak"] = 0
                
                levelInfo["seeds"] = seeds

                json.dump(levelInfo, levelFile, indent = 4, ensure_ascii = False)
                levelFile.close()

    def autoScrape(self, destination, minLevel, maxLevel, skipAudio):
        self.scrapeLevels(minLevel, maxLevel)
        self.writeCourseInfo(destination)
        self.buildSeedbox(skipAudio)
        self.writeSeedbox()
        self.createLevels()