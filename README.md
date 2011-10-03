Dropcaster
==========
Simple Podcast Publishing with Dropbox
--------------------------------------
Author: Nicolas E. Rabenau <nerab@gmx.at>

Description
-----------
Dropcaster is a podcast feed generator for the command line. It is most simple to use with Dropbox, but works equally well with any other hoster.

What is the problem Dropcaster is trying to solve?
==================================================

You have a number of podcast episodes that you would like to publish as a feed. Nothing else - no fancy website, no stats, nothing but the pure podcast.

With Dropcaster, you simply put the mp3 files into the Public folder of your [Dropbox](http://www.dropbox.com/). Then run the Dropcaster script that generates the feed, writing it to a file in your Dropbox, e.g. index.rss. All mp3 files in the Public folder of your Dropbox are already accessible via HTTP, and so will the RSS file. You can then take the RSS file's URL and publish it (again, this is because any file in the Public folder of my Dropbox automatically gets a public, HTTP-accessible URL).

The feed URL can be consumed my any podcatcher, e.g. [iTunes](http://www.apple.com/itunes/) or [Juice](http://juicereceiver.sourceforge.net/).

Meta Data
=========

The meta data for your channel is provided in a YAML file. It is expected to be present in the current working directory as channel.yml. This can be overridden using a command line switch.

For the podcast episodes, the mp3 files are the authoritative meta data source. Dropcaster reads the metadata from the mp3 files and fills the RSS feed from it. 

You may override the meta data for any episode by providing a YAML file with the same name as the mp3 file, but with an extension of yml or yaml (ususally refered to as <a href="http://en.wikipedia.org/wiki/Sidecar_file">sidecar file</a>). Any attributes specified in this file override the ID tags in the mp3 file.

Please note that Dropcaster will only write the sidecar file if the appropriate option was passed, and it will use the information in it only for generating new files like the index.rss. It will not write back to mp3 files.

Use Cases
=========

Publish a New Episode
---------------------

1. Drop the mp3 file into the Dropbox Public folder (e.g. ~/Dropbox/Public), and then run

        $ dropcaster > index.rss

1. Dropbox will sync the updated index.rss file to its web server and any podcast client will download the new episode as soon as it has loaded the updated index.rss.

Delete an Episode
-----------------

Remove the mp3 you want to delete from the Dropbox Public folder, and then run

	  $ dropcaster > index.rss

Replace an Episode With an Updated File
---------------------------------------

In the Dropbox Public folder, replace the mp3 you want to update with a new version, and then run

	  $ dropcaster > index.rss

Publish Your Feed
-----------------

1. Re-generate the feed to make sure the it is up to date:

        $ dropcaster > index.rss
	
1. In your Dropbox Public folder, right-click the index.rss and select Dropbox / Copy public link. This copies the public, HTTP-addressable link to your podcast into the clipboard.
1. Publish this link and tell people to subscribe to it.

Publish More than One Feed
--------------------------

	  $ dropcaster project1 > project1.rss
	  $ dropcaster project2 > project2.rss

or

	  $ cd project1
	  $ dropcaster > index.rss
	  $ cd ../project2
	  $ dropcaster > index.rss

Include Episodes From Two Subdirectories Into a Single Feed
-----------------------------------------------------------

	  $ dropcaster project1 project2 > index.rss

Episode Identifier (uuid)
=========================

Dropcaster uses a rather simple approach to uniquely identify the episodes. It simply generates a SHA1 hash of the mp3 file. If it changes, for whatever reason (even if only a tag was changes), the episode will get a new UUID, and any podcatcher will fetch the episode again (which is what you want, in most cases).

Modifying the sidecar file does not change the UUID, because it only affects the feed and not the episode itself.

A Note on iTunes
================

The generated XML file contains all elements required for iTunes. However, Dropcaster will not notify the iTunes store about new episodes.

Using Dropcaster Without Dropbox
================================

The whole concept of Dropcaster works perfectly fine without Dropbox. Just run the Dropcaster script in a directory of mp3 files and upload the files as well as the generated index.rss to a web server. Leave the relative position of the index and mp3 files as is, otherwise the path to the mp3 files in index.rss will become invalid.
