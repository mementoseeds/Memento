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
import re
import sys
import json
from getopt import getopt, GetoptError
import requests
from pprint import pprint
from bs4 import BeautifulSoup

class MemriseCourse():
    def __init__(self, url):
        # Setup
        self.level = []
        url = url if not url.endswith("/") else url[0:-1]
        courseId = url.split("/")[-2]
        soup = BeautifulSoup(requests.get(url).content, features="lxml")

        # Course title and creator
        top = soup.head.title.string.strip().split(" - ")
        self.title = top[0]
        self.creator = re.sub("^by ", "", top[1].strip())
        del top

        # Course description
        self.description = soup.find("span", class_ = "course-description").string.strip()

        # Course total levels
        lastLevelUrl = soup.find_all("a", class_ = "level")[-1]["href"]
        self.levelAmount = int(lastLevelUrl.split("/")[-2 if lastLevelUrl.endswith("/") else -1])
        del lastLevelUrl

        # Level urls
        self.levelUrls = [url + "/" + str(i) for i in range(1, self.levelAmount + 1)]
        
        # Pool ID
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
        for i in range(max(0, start - 1), min(self.levelAmount, stop)):
            soup = BeautifulSoup(requests.get(self.levelUrls[i]).content, features="lxml")
            levelContent = {}

            levelContent["title"] = soup.find("h3", class_ = "progress-box-title").text.strip()
            print("Scraping", levelContent["title"])
            
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
            levelContent["itemCount"] = len(levelContent["items"])

            # Get level columns
            columnData = soup.find("div", class_ = "things clearfix")
            levelContent["testColumn"] = columnData["data-column-a"]
            levelContent["promptColumn"] = columnData["data-column-b"]
            del columnData

            self.level.append(levelContent)

    def buildSeedbox(self):
        self.seedbox = {}
        uniqueItems = []
        for lvl in self.level:
            for item in lvl["items"]:
                if not item in uniqueItems:
                    uniqueItems.append(item)

        for item in uniqueItems:
            itemInfo = requests.get("https://app.memrise.com/api/thing/get/?thing_id=" + item).json()
            key = str(item)

            self.seedbox[key] = {}
            self.seedbox[key]["attributes"] = itemInfo["thing"]["attributes"]["1"]["val"]
            self.seedbox[key]["audio"] = ""

            # Columns
            for column in itemInfo["thing"]["columns"]:
                if itemInfo["thing"]["columns"][column]["kind"] == "audio":
                    self.seedbox[key]["audio"] = itemInfo["thing"]["columns"][column]["val"][0]["url"]
                
                elif itemInfo["thing"]["columns"][column]["kind"] == "text":
                    self.seedbox[key][self.pool["pool"]["columns"][column]["label"]] = {}
                    
                    self.seedbox[key][self.pool["pool"]["columns"][column]["label"]]["primary"] = itemInfo["thing"]["columns"][column]["val"]
                    
                    self.seedbox[key][self.pool["pool"]["columns"][column]["label"]]["image"] = ""

                    self.seedbox[key][self.pool["pool"]["columns"][column]["label"]]["alternative"] = [alt["val"] for alt in itemInfo["thing"]["columns"][column]["alts"]] if len(itemInfo["thing"]["columns"][column]["alts"]) > 0 else []

minLevel = 0
maxLevel = 9999999

def showHelp():
    print("You must specify only the course url. E.g. --> python scrape_memrise.py https://app.memrise.com/course/63061/capital-cities-2/")
    print("Extra options:")
    print("\t-f --from --> Set the level from which to start downloading")
    print("\t-t --to --> Set the level when to stop downloading")
    print("Examples:")
    print("\tScrape capitals up to level 3 --> python scrape_memrise.py -t 3 https://app.memrise.com/course/63061/capital-cities-2/")
    print("\tScrape capitals from level 3 to the end --> python scrape_memrise.py -f 3 https://app.memrise.com/course/63061/capital-cities-2/")
    print("\tScrape capitals only between levels 2 and 4 --> python scrape_memrise.py -f 2 -t 4 https://app.memrise.com/course/63061/capital-cities-2/")

try:
    opts, args = getopt(sys.argv[1:], "f:t:", ["from=", "to="])
    for o, a in opts:

        if (o in ("-f", "--from")):
            minLevel = int(a)
        
        if (o in ("-t", "--to")):
            maxLevel = int(a)

except GetoptError as e:
    print(e)
    showHelp()
    exit()

if len(args) == 0:
    showHelp()
    exit()

for a in args:
    print("Gathering preliminary data")
    course = MemriseCourse(a)
    course.scrapeLevels(minLevel, maxLevel)
    course.buildSeedbox()

    # if not os.path.isdir(os.path.join(os.getcwd(), course.title)):
    #     os.mkdir(os.path.join(os.getcwd(), course.title))

    pprint(course.seedbox)