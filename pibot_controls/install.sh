#!/bin/bash -e

#  Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
GREEN_B='\033[1;32m'
CYAN='\033[0;36m'
CYAN_B='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' #  No Color

source /opt/ros/noetic/setup.bash

#  Setup simulation files.
printf "${GREEN}Installing ITI0201 simulation...${NC}\n\n"
cd $HOME
if [ -d "catkin_ws" ]; then
  printf "${RED} I will delete $HOME/catkin_ws directory, if you are ready, type 'YES' to continue!${NC}\n"
  read confirm
  if [ "$confirm" = "YES" ]; then
    echo "Deleting catkin_ws..."
  else
    echo "Exiting..."
    exit
  fi
fi
rm -rf catkin_ws
mkdir catkin_ws
cd catkin_ws
printf "${GREEN}Cloning simulation repository...${NC}\n\n"
git clone https://github.com/iti0201/simulation src
source ~/.bashrc
catkin_make -DCMAKE_CXX_FLAGS="-std=c++17"
DIR=$HOME/catkin_ws/src/pibot_controls
printf "\nCreating symlinks...\n\n"
sudo rm -rf /usr/bin/robot_test /usr/bin/script_launch /usr/bin/update_files
sudo ln -s $DIR/robot_test /usr/bin
sudo ln -s $DIR/script_launch /usr/bin
sudo ln -s $DIR/update_files /usr/bin

#  Check if python is installed.
printf "Checking python...\n"
if [ -x "$(command -v python3.9)" ]; then
  printf "${GREEN}Python 3.9 detected!${NC}\n"
else
  printf "${RED}Python 3.9 is not installed!\n Installing...!${NC}\n"
  sudo apt-get update
  sudo apt-get install -y python3.9
fi

#  Check if pip is installed.
if ! [ -x "$(command -v pip3)" ]; then
  printf "${GREEN}Installing pip...${NC}\n"
  sudo apt-get install -y python3-pip
  printf "${GREEN}pip3 is installed!${NC}\n"
else
  printf "${GREEN}pip3 detected!${NC}\n\n"
fi

# Check python directories
printf "\nChecking python directories...\n"
declare -a dirs=("python3.8" "python3.9")
for dir in "${dirs[@]}"
do
  if [ -d ~/.local/lib/$dir/site-packages ]; then
    printf "${GREEN}lib/$dir/site-packages detected!${NC}\n"
  else
    printf "${RED}lib/$dir/site-packages is missing! Creating...${NC}\n"
    mkdir -p ~/.local/lib/$dir/site-packages
    printf "${GREEN}lib/$dir/site-packages is created.${NC}\n"
  fi

  rm -f ~/.local/lib/$dir/site-packages/PiBot.py
  rm -f ~/.local/lib/$dir/site-packages/image_processor.py
  ln -s ~/catkin_ws/src/pibot_controls/PiBot.py ~/.local/lib/$dir/site-packages
  ln -s ~/catkin_ws/src/pibot_controls/image_processor.py ~/.local/lib/$dir/site-packages
done

#PYTHONDIR=~/.local/lib/$(ls ~/.local/lib/ | grep python3)/site-packages
#printf "${GREEN}Python directory is ${NC}$PYTHONDIR\n"

# PiBot.py file transaction.
#rm -f $PYTHONDIR/PiBot.py
#ln -s ~/catkin_ws/src/pibot_controls/PiBot.py $PYTHONDIR

# Add catkin workspace to bashrc
printf "\nAdding sourcing to .bashrc"
echo "source $HOME/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc

printf "\n${YELLOW}The script has finished successfully!${NC}
Before you start developing, you need to set the bashrc to the correct source.
To do that write into the terminal ${CYAN}vim ~/.bashrc${NC}
The source variables at the bottom of the file have to be
${CYAN}source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash${NC}
${YELLOW}Now you are done!${NC}\n\n"
