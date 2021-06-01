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
import sys
from getopt import getopt, GetoptError
import requests
from bs4 import BeautifulSoup

minLevel = 1
maxlevel = 9999999

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
            minlevel = int(a)
        
        if (o in ("-t", "--to")):
            maxlevel = int(a)

except GetoptError as e:
    print(e)
    showHelp()
    exit()

if len(args) == 0:
    showHelp()
    exit()

for a in args:
    soup = BeautifulSoup(requests.get(a).content, features="lxml")

    # Course title and creator
    top = soup.head.title.string.strip().split(" - ")
    title = top[0]
    creator = re.sub("^by ", "", top[1].strip())
    del top

    # Course description
    description = soup.find("span", class_ = "course-description").string.strip()

    # Course total levels
    lastLevelUrl = soup.find_all("a", class_ = "level")[-1]["href"]
    levelAmount = int(lastLevelUrl.split("/")[-2 if lastLevelUrl.endswith("/") else -1])
    del lastLevelUrl

    # SPECIFIC LEVELS
    for i in range(max(1, minlevel), min(levelAmount, maxlevel) + 1):
        soup = BeautifulSoup(requests.get(join(a, str(i))).content, features="lxml")

        levelTitle = soup.find("h3", class_ = "progress-box-title").text.strip()

        for i in soup.find_all("div", class_ = "thing text-text"):
            testColumn = i.find("div", class_ = "col_a col text").text.strip()
            promptColumn = i.find("div", class_ = "col_b col text").text.strip()
            print(testColumn, promptColumn)
        
        print()