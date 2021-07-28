#!/bin/bash

install_msg="You going to install grub theme. Do you want to CONTINUE? (Y/n)"
installation_canceled_msg="Installation canceled"
PS3='Please select your laptop: '
options=("ProX" "Titan" "Essential" "One" "Zero" "Kymera" "Executive" "Other")
grub_path=/boot/grub
themes_path=$grub_path/themes
slimbook_theme_path=$themes_path/slimbook
grub_cgf_path=/etc/default/grub

# set -x			# activate debugging from here

###############################################################################
# INFO
###############################################################################
echo "**************************************************"
echo "* Wellcome to SLIMBOOK grub theme installer *"
echo "* SLIMBOOK TEAM @SlimbookEs @_javiernogales *"
echo "**************************************************"
echo ""

###############################################################################
# INSTALLATION CONTINUE QUESTION
###############################################################################
count=0
while [ $count -lt 3 ]
do 
    echo $install_msg
    read CONTINUE
    if [ -z $CONTINUE ]
    then
        CONTINUE="Y"
    fi
    if [ $CONTINUE = 'N' ] || [ $CONTINUE = 'n' ] || [ $CONTINUE = 'Y' ] || [ $CONTINUE = 'y' ]
    then    
        break
    fi
    count=$((count+1))
done

if [ $CONTINUE != 'Y' ] && [ $CONTINUE != 'y' ]
then
    echo $installation_canceled_msg
    exit 0
fi

#diferent logo for each laptop model
select opt in "${options[@]}"
do
    model="src/images/"$(echo $opt | tr '[:upper:]' '[:lower:]')".png"
    if [ -f $model ]
    then
       cp $model src/images/logo.png
    fi
    break
done

#grub path
if [ ! -d $grub_path ]
then
    echo $installation_canceled_msg
    echo "grub is not installed"
    exit 1
fi

#themes path
if [ ! -d $themes_path ]
then
    echo "creating themes folder..."
    sudo mkdir $themes_path
fi

#slimbook theme path
if [ -d $slimbook_theme_path ]
then
    echo "remove old slimbook theme folder"
    sudo rm -R $slimbook_theme_path
fi


echo "creating slimbook theme folder..."
sudo mkdir $slimbook_theme_path

echo "loading fonts..."
sudo cp ./src/fonts/* $slimbook_theme_path

echo "loading OS icons..."
sudo cp -r ./src/icons $slimbook_theme_path

echo "loading images..."
sudo cp -r ./src/images $slimbook_theme_path
sudo cp -r ./src/pixmap $slimbook_theme_path

echo "copying theme.txt..."
sudo cp ./src/theme.txt $slimbook_theme_path/theme.txt

#grub config
echo "modifying grub config..."
# 

if grep -q "^GRUB_GFXMODE" $grub_cgf_path
then
    # case a: variable GRUB_GFXMODE uncommented found
    echo "variable GRUB_GFXMODE uncommented found."
    sed -i -e '/^GRUB_GFXMODE*/c\GRUB_GFXMODE=1920x1080x32' $grub_cgf_path
else
    if grep -q "^#GRUB_GFXMODE" $grub_cgf_path
    then
        # case b: variable GRUB_GFXMODE commented found
        echo "variable GRUB_GFXMODE commented found."
        sed -i -e '/^#GRUB_GFXMODE*/c\GRUB_GFXMODE=1920x1080x32' $grub_cgf_path
    else
        # case c: variable GRUB_GFXMODE not found
        echo "writting GRUB_GFXMODE value..."
        echo "GRUB_GFXMODE=1920x1080x32" | sudo tee -a $grub_cgf_path
    fi
fi

if grep -q "^GRUB_THEME" $grub_cgf_path
then
    # case a: variable GRUB_THEME uncommented found
    echo "variable GRUB_THEME uncommented found!"
    sed -i -e '/^GRUB_THEME*/c\GRUB_THEME="/boot/grub/themes/slimbook/theme.txt"' $grub_cgf_path
else
    if grep -q "^#GRUB_THEME" $grub_cgf_path
    then
        # case b: variable GRUB_THEME commented found
        echo "vafiable GRUB_THEME commented found!"
        sed -i -e '/^#GRUB_THEME*/c\GRUB_THEME="/boot/grub/themes/slimbook/theme.txt"' $grub_cgf_path
    else
        # case c: variable GRUB_THEME not found
        echo "writting GRUB_THEME value..."
        echo 'GRUB_THEME="/boot/grub/themes/slimbook/theme.txt"' | sudo tee -a $grub_cgf_path
    fi
fi

echo "updating grub..."
sudo update-grub

# set +x			# stop debugging from here
