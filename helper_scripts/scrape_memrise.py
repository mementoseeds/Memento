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
from MemriseCourse import MemriseCourse
import traceback

try:
    import beepy
except ModuleNotFoundError:
    print("Install pip module \"beepy\" to enable playing sounds\n")

minLevel = 0
maxLevel = 9999999
destination = os.getcwd()
cookie = ""
skipAudio = False
skipMnemonics = False

def showHelp():
    print("This is a script to scrape Memrise courses and convert them to Mememto-compatible ones. It first gathers general information from the course's home page. Afterwards it visits each level to get its title and the items in it. Finally it will call the Memrise API to extract extra information about an item, such as its attributes or audio.")
    print("You must specify only the course url. E.g. --> python scrape_memrise.py https://app.memrise.com/course/63061/capital-cities-2/")
    print("Extra options:")
    print("\t-h --help --> Show this help page")
    print("\t-f --from --> Set the level from which to start downloading")
    print("\t-t --to --> Set the level when to stop downloading")
    print("\t-d --destination --> Set the download destination")
    print("\t-c --cookie --> Set your login cookie to download courses that have only one level")
    print("\t-n --no-audio --> Do not download any audio columns")
    print("\t-m --no-mnemonics --> Do not download any mnemonics")
    print("Examples:")
    print("\tScrape capitals up to level 3 --> python scrape_memrise.py -t 3 https://app.memrise.com/course/63061/capital-cities-2/")
    print("\tScrape capitals from level 3 to the end --> python scrape_memrise.py -f 3 https://app.memrise.com/course/63061/capital-cities-2/")
    print("\tScrape capitals only between levels 2 and 4 --> python scrape_memrise.py -f 2 -t 4 https://app.memrise.com/course/63061/capital-cities-2/")
    print("\tScrape a single-level course like \"Nato Alphabet\" that requires you to be logged in --> python scrape_memrise.py -c 'your login cookie' https://app.memrise.com/course/31682/nato-alphabet-3/")

try:
    opts, args = getopt(sys.argv[1:], "hf:t:d:c:nm", ["help", "from=", "to=", "destination=", "cookie=", "no-audio", "no-mnemonics"])
    for o, a in opts:

        if (o in ("-h", "--help")):
            showHelp()
            exit()

        if (o in ("-f", "--from")):
            minLevel = int(a)

        if (o in ("-t", "--to")):
            maxLevel = int(a)

        if (o in ("-d", "--destination")):
            destination = a

        if (o in ("-c", "--cookie")):
            cookie = a

        if (o in ("-n", "--no-audio")):
            skipAudio = True

        if (o in ("-m", "--no-mnemonics")):
            skipMnemonics = True

except (GetoptError, ValueError) as e:
    print(e)
    showHelp()
    exit()

if len(args) == 0:
    showHelp()
    exit()

print("Download audio -", not skipAudio)
print("Download mnemonics -", not skipMnemonics)

if not skipAudio:
    print("\n***Warning*** downloading audio can affect download duration and course size\n")

if not skipMnemonics:
    print("\n***Warning*** downloading mnemonics can significantly affect download duration\n")

for a in args:
    try:
        course = MemriseCourse(a, destination, cookie)
        course.autoScrape(destination, minLevel, maxLevel, skipAudio, skipMnemonics)
        print()

    except KeyboardInterrupt:
        exit("\n\nAborting")

    except Exception as e:
        print("\n\nCaught exception\n", traceback.format_exc(), "\nContinuing to next course\n\n")

        try:
            beepy.beep(sound = "error")
        except NameError:
            pass

        continue

try:
    beepy.beep(sound = "ready")
except NameError:
    pass
