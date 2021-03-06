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
import time
from bs4 import BeautifulSoup

class MemriseCourse():

    memriseApi = "https://app.memrise.com/api/"
    memriseImages = "https://static.memrise.com/"
    memriseUrl = "https://app.memrise.com"

    headers = {}

    forbiddenFileCharacters = "[<>:\"\'|?*]"

    thingPattern = re.compile("thing \w+-\w+")
    testColumnTypePattern = re.compile("col_a col \w+")
    promptColumnTypePattern = re.compile("col_b col \w+")

    def __init__(self, url, destination, cookie):
        # Setup
        #print("Gathering preliminary data")

        MemriseCourse.headers["cookie"] = cookie

        self.itemPools = {}
        self.itemLearnables = {}
        self.level = []
        self.itemCount = 0

        url = url if not url.endswith("/") else url[0:-1]
        courseId = url.split("/")[-2]
        soup = BeautifulSoup(requests.get(url + "/", headers = MemriseCourse.headers).content, features = "lxml")

        # Course title and author
        #print("Scraping course title and author")
        self.title = soup.find("h1", class_ = "course-name sel-course-name").text.strip().replace("/", "∕")
        print("Scraping", self.title)

        __headTitle = soup.head.title.string.strip().split(" - ")[-2].strip()
        if __headTitle.startswith("by "):
            self.author = re.sub("^by ", "", __headTitle)
        else:
            self.author = "Memrise"

        # Course category
        print("Scraping course category")
        self.category = soup.find("div", class_ = "course-breadcrumb").find_all("a")[-1].string.strip()

        # Course icon
        print("Scraping course icon")
        self.iconUrl = soup.find("a", class_ = "course-photo").find_next("img")["src"]

        # Course description
        print("Scraping course description")
        try:
            self.description = soup.find("span", class_ = "course-description").string.strip()
        except AttributeError:
            print("No description found")
            self.description = ""

        try:
            # Course total levels
            print("Scraping level count")
            __lastLevelUrl = soup.find_all("a", class_ = "level")[-1]["href"]
            self.levelAmount = int(__lastLevelUrl.split("/")[-2 if __lastLevelUrl.endswith("/") else -1])

            # Level urls
            print("Building level URLs")
            self.levelUrls = [url + "/" + str(i) for i in range(1, self.levelAmount + 1)]
        except IndexError:
            print("Detected course with single level")

            try:
                self.author = soup.find("span", itemprop = "additionalName").string.strip()
            except AttributeError:
                self.author = "Memrise"

            self.levelAmount = 1
            self.levelUrls = [url]

        # Pool ID
        print("Finding pool ID")

        randomThingId = None
        for i in self.levelUrls:
            soup = BeautifulSoup(requests.get(i + "/", headers = MemriseCourse.headers).content, features = "lxml")
            thing = soup.find("div", class_ = MemriseCourse.thingPattern)
            if thing:
                randomThingId = thing["data-thing-id"]
                break

        if randomThingId == None:
            raise Exception("Course has no learning levels or course has only one level which cannot be downloaded without logging in")

        poolId = requests.get(MemriseCourse.memriseApi + "thing/get/?thing_id=" + randomThingId).json()["thing"]["pool_id"]
        self.pools = {}
        self.pools[poolId] = requests.get(MemriseCourse.memriseApi + "pool/get/?pool_id=" + str(poolId)).json()

        # Find which columns to show after tests
        print("Finding columns to show after tests")
        self.showAfterTests = []
        for column in self.pools[poolId]["pool"]["columns"]:
            if self.pools[poolId]["pool"]["columns"][column]["show_after_tests"] or self.pools[poolId]["pool"]["columns"][column]["always_show"]:
                self.showAfterTests.append(self.pools[poolId]["pool"]["columns"][column]["label"])

        # Find new name if dir already exists
        self.cleanedTitle = re.sub(MemriseCourse.forbiddenFileCharacters, "", self.title)
        while True:
            if os.path.isdir(join(destination, self.cleanedTitle)):
                print("\n***ERROR*** directory for course", self.cleanedTitle, "already exists. Generating new name...")
                self.cleanedTitle += "-" + str(time.time())
            else:
                break

    def scrapeLevels(self, start, stop):
        print()

        for i in range(max(0, start - 1), min(self.levelAmount, stop)):
            soup = BeautifulSoup(requests.get(self.levelUrls[i] + "/", headers = MemriseCourse.headers).content, features = "lxml")
            levelContent = {}

            try:
                levelContent["title"] = soup.find("h3", class_ = "progress-box-title").text.strip()
            except AttributeError:
                levelContent["title"] = self.title

            print("Reading level", levelContent["title"])

            # Skip grammar levels in official Memrise courses
            if soup.find("div", class_ = "grammar-not-available"):
                print("Skipping grammar level", levelContent["title"])
                continue

            # Handle separately if the level is multimedia
            if soup.find("div", class_ = "multimedia-wrapper"):
                levelContent["isMultimedia"] = True

                pattern = re.compile("var level_multimedia = '(.*?)';$", re.MULTILINE)

                try:
                    rawMedia = soup.find("script", text = pattern).string.strip()
                except AttributeError:
                    rawMedia = "This media level is empty."
                    print(rawMedia)

                cleanMedia = re.sub("^var level_multimedia = '|';$", "", rawMedia)

                # Remove link embeds
                cleanMedia = re.sub("embed:", "", cleanMedia)

                # Properly decode markdown text
                cleanMedia = cleanMedia.encode("utf-8").decode('unicode-escape').encode('latin1').decode('utf-8')

                # Convert img to embedded markdown image
                cleanMedia = re.sub("img:([^\s\n]+)", "![\\1](\\1)", cleanMedia)

                levelContent["mediaContent"] = cleanMedia
                self.level.append(levelContent)

                continue

            # Handle if it is a normal level
            levelContent["isMultimedia"] = False

            # Get column types
            try:
                levelContent["testColumnType"] = soup.find("div", class_ = MemriseCourse.testColumnTypePattern)["class"][-1]
                levelContent["promptColumnType"] = soup.find("div", class_ = MemriseCourse.promptColumnTypePattern)["class"][-1]
            except TypeError:
                print("***ERROR*** This level is empty")
                continue

            # Gather item IDs
            levelContent["items"] = []
            for item in soup.find_all("div", class_ = MemriseCourse.thingPattern):
                levelContent["items"].append(item["data-thing-id"])
                self.itemLearnables[item["data-thing-id"]] = item["data-learnable-id"]

            self.itemCount += len(levelContent["items"])

            # Get level columns
            __columnData = soup.find("div", class_ = "things clearfix")
            levelContent["testColumn"] = __columnData["data-column-a"]
            levelContent["promptColumn"] = __columnData["data-column-b"]

            self.level.append(levelContent)

    def writeCourseInfo(self, destination):
        self.courseDir = join(destination, self.cleanedTitle)

        try:
            os.mkdir(self.courseDir)

            print("\nmkdir", self.courseDir, "\n")

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
            "author": self.author,
            "description": self.description,
            "category": self.category,
            "icon": "assets/images/icon.jpg",
            "items": self.itemCount,
            "showAfterTests": self.showAfterTests,
            "planted": 0,
            "water": 0,
            "difficult": 0,
            "ignored": 0,
            "completed": False}

        # Write course info json
        json.dump(courseInfo, open(join(self.courseDir, "info.json"), "w", encoding = "utf-8"), indent = 4, ensure_ascii = False)


    def buildSeedbox(self, skipAudio, skipMnemonics):
        print("Finding unique items across all levels")

        self.mnemonics = {}
        self.seedbox = {}
        uniqueItems = []
        for lvl in self.level:
            if not lvl["isMultimedia"]:
                for item in lvl["items"]:
                    if not item in uniqueItems:
                        uniqueItems.append(item)

        print("Finding item information from Memrise API\n")

        counter = 1
        totalUniqueItems = len(uniqueItems)
        for item in uniqueItems:
            print("Scraping item", counter, "of", totalUniqueItems, end = "\r", flush = True)
            counter += 1

            itemInfo = requests.get(MemriseCourse.memriseApi + "thing/get/?thing_id=" + item).json()
            key = str(item)

            restartLoop = True
            while restartLoop:
                restartLoop = False

                # Set pool ID for this item
                self.itemPools[str(itemInfo["thing"]["id"])] = itemInfo["thing"]["pool_id"]

                # Attributes
                self.seedbox[key] = {}
                self.seedbox[key]["attributes"] = {}
                try:
                    for number in itemInfo["thing"]["attributes"]:
                            self.seedbox[key]["attributes"][number] = {}

                            try:
                                self.seedbox[key]["attributes"][number]["label"] = self.pools[itemInfo["thing"]["pool_id"]]["pool"]["attributes"][number]["label"]
                                self.seedbox[key]["attributes"][number]["showAtTests"] = self.pools[itemInfo["thing"]["pool_id"]]["pool"]["attributes"][number]["show_at_tests"]
                            except KeyError:
                                self.seedbox[key]["attributes"][number]["label"] = "Unnamed"
                                self.seedbox[key]["attributes"][number]["showAtTests"] = False

                            self.seedbox[key]["attributes"][number]["value"] = itemInfo["thing"]["attributes"][number]["val"]

                    # Columns
                    for column in itemInfo["thing"]["columns"]:

                        # Audio column
                        if itemInfo["thing"]["columns"][column]["kind"] == "audio" and not skipAudio:
                            self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]] = {}
                            self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]]["type"] = "audio"
                            audioArray = []

                            for audio in itemInfo["thing"]["columns"][column]["val"]:
                                audioName = audio["url"].split("/")[-1]
                                open(join(self.courseDir, "assets", "audio", audioName), "wb").write(requests.get(audio["url"]).content)
                                audioArray.append("assets/audio/" + audioName)

                            self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]]["primary"] = ":".join(audioArray)

                        # Image column
                        elif itemInfo["thing"]["columns"][column]["kind"] == "image":
                            try:
                                self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]] = {}
                                self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]]["type"] = "image"

                                imageName = itemInfo["thing"]["columns"][column]["val"][0]["url"].split("/")[-1]
                                open(join(self.courseDir, "assets", "images", imageName), "wb").write(requests.get(MemriseCourse.memriseImages + itemInfo["thing"]["columns"][column]["val"][0]["url"]).content)

                                self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]]["primary"] = "assets/images/" + imageName
                            except IndexError:
                                print("Item", itemInfo["thing"]["id"], "of type image in course", "\"" + self.title + "\"", "does not have an image URL.")
                                self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]]["primary"] = "assets/images/icon.jpg"

                        # Text column
                        elif itemInfo["thing"]["columns"][column]["kind"] == "text":
                            self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]] = {}

                            self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]]["type"] = "text"

                            self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]]["primary"] = itemInfo["thing"]["columns"][column]["val"].strip()

                            self.seedbox[key][self.pools[itemInfo["thing"]["pool_id"]]["pool"]["columns"][column]["label"]]["alternative"] = [alt["val"] for alt in itemInfo["thing"]["columns"][column]["alts"]] if len(itemInfo["thing"]["columns"][column]["alts"]) > 0 else []

                    # Mnemonics
                    if not skipMnemonics:
                        mnemonicsJson = requests.get(MemriseCourse.memriseApi + "mem/get_many_for_thing/?thing_id=" + key + "&learnable_id=" + self.itemLearnables[key]).json()

                        self.mnemonics[key] = {}
                        for mem in mnemonicsJson["mems"]:
                            memId = str(mem["id"])

                            self.mnemonics[key][memId] = {}
                            self.mnemonics[key][memId]["author"] = mem["author"]["username"]
                            self.mnemonics[key][memId]["text"] = mem["text"]

                            if mem["image_original"]:
                                imageTitle = "mnemonic-" + key + "-" + memId + ".jpg"
                                open(join(self.courseDir, "assets", "images", imageTitle), "wb").write(requests.get(MemriseCourse.memriseUrl + mem["image_original"]).content)
                                self.mnemonics[key][memId]["image"] = "assets/images/" + imageTitle
                            else:
                                self.mnemonics[key][memId]["image"] = ""


                except KeyError:
                    print("\nSwitching database\n")
                    newPoolId = itemInfo["thing"]["pool_id"]
                    self.pools[newPoolId] = requests.get(MemriseCourse.memriseApi + "pool/get/?pool_id=" + str(newPoolId)).json()
                    restartLoop = True # Restart from the beginning of the while loop without skipping the current item where the exception occurred

                except ConnectionResetError:
                    print("Connection reset error. Retrying...")
                    restartLoop = True


    def writeSeedbox(self):
        print("Writing seedbox.json and mnemonics.json")
        json.dump(self.seedbox, open(join(self.courseDir, "seedbox.json"), "w", encoding = "utf-8"), indent = 4, ensure_ascii = False)
        json.dump(self.mnemonics, open(join(self.courseDir, "mnemonics.json"), "w", encoding = "utf-8"), indent = 4, ensure_ascii = False)

    def createLevels(self):
        print("Creating level files")

        for i in range(0, len(self.level)):
            if self.level[i]["isMultimedia"]:
                levelFile = open(join(self.courseDir, "levels", str(i + 1).zfill(5) + ".md"), "w", encoding = "utf-8")
                levelFile.write("[comment]: <> (" + self.level[i]["title"] + ")\n")
                levelFile.write(self.level[i]["mediaContent"])
                levelFile.close()

            else:
                levelFile = open(join(self.courseDir, "levels", str(i + 1).zfill(5) + ".json"), "w", encoding = "utf-8")
                levelInfo = {"title": self.level[i]["title"],
                    "completed": False,
                    "test": self.pools[self.itemPools[self.level[i]["items"][0]]]["pool"]["columns"][self.level[i]["testColumn"]]["label"],
                    "prompt": self.pools[self.itemPools[self.level[i]["items"][0]]]["pool"]["columns"][self.level[i]["promptColumn"]]["label"],
                    "testType": self.level[i]["testColumnType"],
                    "promptType": self.level[i]["promptColumnType"]}

                seeds = {}
                for item in self.level[i]["items"]:
                    seeds[item] = {"planted": False,
                    "nextWatering": "",
                    "ignored": False,
                    "difficult": False,
                    "successes": 0,
                    "failures": 0,
                    "streak": 0,
                    "mnemonic": ""}

                levelInfo["seeds"] = seeds

                json.dump(levelInfo, levelFile, indent = 4, ensure_ascii = False)
                levelFile.close()

    def autoScrape(self, destination, minLevel, maxLevel, skipAudio, skipMnemonics):
        self.scrapeLevels(minLevel, maxLevel)
        self.writeCourseInfo(destination)
        self.buildSeedbox(skipAudio, skipMnemonics)
        self.writeSeedbox()
        self.createLevels()