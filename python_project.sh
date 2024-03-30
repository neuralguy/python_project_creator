#!/bin/bash


type=none
dir_name="Python_project"


ctrl_c() {
    cd ..
    rm -rf $dir_name
    echo 
    echo "[~] You interrupted the project creation process. All generated files were deleted"
    exit 0
}


trap ctrl_c SIGINT


create_file() {
  if [ -f "$1" ]; then
    echo [-] $1 file already exists
    exit 1
  else
    touch "$1"
    if [ $? -eq 0 ]; then
        echo [+] $1 file has been created
    else
        echo [-] Failed to create $1 file
        exit 1
    fi
  fi
}


create_dir() {
  if [ -d "$1" ]; then
    echo [-] $1 directory already exists
    exit 1
  else
    mkdir "$1"
    if [ $? -eq 0 ]; then
        echo [+] $1 directory has been created
    else
        echo [-] Failed to create $1 directory
        exit 1
    fi
  fi
}


pip_install() {
    pip install "$1" > /dev/null 2>&1 &
    local loading_message=""
    local loading_animation=( '—' "\\" '|' '/' )

    tput civis
    echo -n "[~] Installing $1 "

    while ps -p $! > /dev/null; do
        for frame in "${loading_animation[@]}" ; do
            printf "%s\b" "${frame}"
            sleep 0.25
        done
    done
    printf "\r"
    tput el
    echo [+] $1 has been installed succesfully
    tput cnorm
}


while [[ $# -gt 0 ]]; do
  case "$1" in
  	-h | --help)
        echo "Usage: pyproj [options...]

-h, --help            Show this message
-p, --project-type    Choose type of a new project. Available types: 
                      django
                      aiogram
                      pygame
-d, --directory-name  Name for main directory"            
        exit 1
        ;;
    -p | --project-type)
        shift
        case "$1" in
            aiogram | django | pygame)
            project_type="$1"
            ;;
            *)
            echo "[-] No such type of project, here are the available ones:
django
aiogram
pygame"
            exit 1
            ;;
        esac
        ;;
    -d | --directory-name)
        shift
        dir_name="$1"
        ;;
    *)
      echo Unknown option: $1, type -h or --help for info
      exit 1
      ;;
  esac
  shift
done

spaces=""
for ((i=1; i<${#dir_name}; i++)); do
    spaces+=" "
done

create_dir $dir_name
cd $dir_name

if [ -d "venv" ]; then
    echo [-] Directory venv already exists
  else
    python3 -m venv venv > /dev/null 2>&1
    echo [+] Virtual enviroment has been created with name 'venv'
fi
source venv/bin/activate

create_file "main.py"
create_file "test.py"
create_file "requirements.txt"
create_file "README.txt"

if [ -d ".git" ]; then
    echo [-] .git already exists
  else
    git init > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo [+] git repository is initialized
    else
      echo [-] Failed to initialize git repository
      exit 1
    fi
fi

case $project_type in
	aiogram)
	pip_install aiogram
    echo aiogram==$(pip show aiogram | grep Version | cut -d ' ' -f2) > requirements.txt
    echo "import asyncio
from aiogram import Bot, Dispatcher, types, F
from config import TOKEN
from handlers.text_handlers import text_router
from handlers.image_handlers import image_router
from handlers.inline_handlers import inline_router


bot=Bot(token=TOKEN)
dp = Dispatcher()
dp.include_router(text_router)
dp.include_router(image_router)
dp.include_router(inline_router)


async def main():
    await bot.delete_webhook(drop_pending_updates=True)
    await dp.start_polling(bot)


if __name__ == '__main__':
    asyncio.run(main())" > main.py

    create_file log.txt
    create_file config.py
    echo "TOKEN = 'Enter your token here'" > config.py
    create_file keyboards.py
    create_file strings.py
    create_dir images
    create_dir handlers
    create_file handlers/text_handlers.py
    echo "from aiogram import types, Router, F
from aiogram.filters import Command


text_router = Router()


@text_router.message(F.text)
async def handle_message(message: types.Message):
    await message.answer('Привет, я ботик')" > text_handlers.py

    create_file handlers/image_handlers.py
    echo "from aiogram import types, Router, F
from aiogram.filters import Command


image_router = Router()" > image_handlers.py

    create_file handlers/inline_handlers.py
    echo "from aiogram import types, Router, F
from aiogram.filters import Command


inline_router = Router()" > inline_handlers.py
    echo "[+] All done, structure:
$dir_name┓
$spaces handlers┓   
$spaces ┳       image_handlers.py
$spaces ┃       inline_handlers.py
$spaces ┻       text_handlers.py
$spaces images
$spaces venv━━━━┓
$spaces ┳       bin
$spaces ┃       include
$spaces ┃       lib
$spaces ┃       lib64
$spaces ┻       pyvenv.cfg
$spaces config.py
$spaces keyboards.py
$spaces log.txt
$spaces main.py
$spaces README.txt
$spaces requirements.txt
$spaces strings.py
$spaces test.py"
	;;
    django)
    pip_install Django
    echo Django==$(pip show Django | grep Version | cut -d ' ' -f2) > requirements.txt
    tput cnorm
    echo -n [~] "Enter name for your project: "
    read project_name
    tput civis
    rm main.py
    python3 -m django startproject $project_name
    mv README.txt $project_name/README.txt
    mv requirements.txt $project_name/requirements.txt
    mv test.py $project_name/test.py
    echo "[+] All done, structure:
$dir_name┓
$spaces $project_name━┓
$spaces ┳   $project_name┓
$spaces ┃   ┳   __init__.py
$spaces ┃   ┃   asgi.py
$spaces ┃   ┃   settings.py
$spaces ┃   ┃   urls.py
$spaces ┃   ┻   wsgi.py
$spaces ┃   manage.py
$spaces ┃   README.txt
$spaces ┃   requirements.txt
$spaces ┻   test.py
$spaces venv┓
$spaces     bin
$spaces     include
$spaces     lib
$spaces     lib64
$spaces     pyvenv.cfg"
    ;;
    pygame)
    pip_install pygame
    pip_install pygame_gui
    create_file config.py
    echo "import pygame


WIDTH = 500
HEIGHT = 500
SCREEN = pygame.display.set_mode((WIDTH, HEIGHT))

GAME_TITLE = 'My game'

CLOCK = pygame.time.Clock()
FPS = 60


class Colors:
    red = (255,0,0)
    green = (0,255,0)
    blue = (0,0,255)
    black = (0,0,0)
    white = (255,255,255)" > config.py

    echo "import pygame
import random as rd
import time 
from config import *


def main():
    pygame.display.set_caption(GAME_TITLE)
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                exit()
            if event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                print(pygame.mouse.get_pos())

        screen.fill(Colors.black)
        pygame.display.update()
        CLOCK.tick(FPS)


if __name__ == '__main__':
    pygame.init()
    main()" > main.py

    echo pygame==$(pip show pygame | grep Version | cut -d ' ' -f2) > requirements.txt
    echo pygame_gui==$(pip show pygame_gui | grep Version | cut -d ' ' -f2) >> requirements.txt
    create_dir src
    create_dir src/audio
    create_dir src/images
    create_dir src/tilemaps
    create_dir ui
    create_file ui/main_ui.py
    create_file sprite.py

    echo "[+] All done, structure:
$dir_name┓
$spaces src━┓
$spaces ┳   audio
$spaces ┃   images
$spaces ┻   tilemaps
$spaces ui━━┓ 
$spaces ┃   main_ui.py
$spaces venv┓
$spaces ┳   bin
$spaces ┃   include
$spaces ┃   lib
$spaces ┃   lib64
$spaces ┻   pyvenv.cfg
$spaces config.py
$spaces main.py
$spaces README.txt
$spaces requirements.txt
$spaces sprite.py
$spaces test.py"
    ;;
esac
exit 0
