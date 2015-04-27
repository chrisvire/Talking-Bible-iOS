# Building
build:
	bumpversion
	xctool

bumpversion:
	agvtool next-version -all

xctool:
	xctool clean
	xctool build

# Preparation for building
prepare: 
	strings
	constants

strings:
	./Scripts/update_storyboard_strings.sh
	./Scripts/update_storyboard_strings.sh

constants:
	swiftrsrc generate TalkingBible/Base.lproj/Main.storyboard TalkingBible/_MainStoryboard.swift
	swiftrsrc generate Images.xcassets TalkingBible/_ImagesCatalog.swift
