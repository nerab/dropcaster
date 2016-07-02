# Dropcaster - Simple Podcast Publishing with Dropbox

[![Build Status](https://travis-ci.org/nerab/dropcaster.png?branch=master)](https://travis-ci.org/nerab/dropcaster)

  _This project is developed with the [readme-driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) method. This file contains the vision, whereas the [README](README.markdown) reflects the functionality that is actually implemented._

[Dropcaster](http://nerab.github.io/dropcaster/) is a podcast feed generator for the command line. It is most simple to use with Dropbox, but works equally well with any other (static file) web hoster.

Author: Nicolas E. Rabenau <nerab@gmx.at>

# What is the problem that Dropcaster is trying to solve?

You have a number of podcast episodes that you would like to publish as a feed. Nothing else - no fancy website, no stats, nothing but the pure podcast.

With Dropcaster, you simply put the mp3 files into the Public folder of your [Dropbox](http://www.dropbox.com/). Then run the Dropcaster script that generates the feed, writing it to a file in your Dropbox, e.g. index.rss. All mp3 files in the Public folder of your Dropbox are already accessible via HTTP, and so will the RSS file. You can then take the RSS file's URL and publish it (again, this is because any file in the Public folder of a Dropbox automatically gets a public, HTTP-accessible URL).

The feed URL can be consumed by any podcatcher, e.g. [iTunes](http://www.apple.com/itunes/) or [Juice](http://juicereceiver.sourceforge.net/).

# Installation

To get started, use RubyGems to install Dropcaster:

    $ gem install dropcaster

Once installed, you can use the `dropcaster` command to generate a new podcast feed document.

# Basic Usage

Once Dropcaster is installed, the only two other things you will need are a channel definition and one or more mp3 files to publish.

Let's start with the channel definition. It is a simple [YAML](http://yaml.org/) file that holds the general information about your podcast channel. According to the [RSS 2.0 spec](http://blogs.law.harvard.edu/tech/rss#requiredChannelElements), the only mandatory information that your channel absolutely needs are a title, a description and a link to a web site where the channel belongs to.

The simplest channel file looks like this:

		:title: 'All About Everything'
		:subtitle: 'A show about everything'
		:url: 'http://www.example.com/podcasts/everything/index.html'

Store this file as channel.yml in the same directory where the mp3 files of your podcast reside. The channel definition is expected to be present in the same directory as your mp3 files, but this can be overridden using a command line switch. You can find a [more elaborate example](http://github.com/nerab/dropcaster/blob/master/doc/sample-channel.yml) for the channel definition in the doc folder of the Dropcaster gem. You can find it by running `gem open dropcaster`.

Now that we have the podcast channel defined, we need at least one episode (an audio file) in it. From Dropcaster's perspective, it does not matter how the episode was produced, but the critical information is the meta data in the mp3 file, because that is the authoritative source for the episode information. Almost all audio editors can write metadata, usually called ID3 tags. Dropcaster reads these tags from the mp3 files and fills the item element in the feed (that's how an episode is defined, technically) from it.

With all required pieces in place, we could generate the podcast feed. Just before we do that, we will inspect the feed by running the following commands:

    $ cd ~/Dropbox/Public
    $ dropcaster

(The above lines assume that you are using Dropbox, and that there is at least one mp3 file in `~/Dropbox/Public`).

Dropcaster will print the feed to standard-out, without writing it to disk. When you are happy with the results, call Dropcaster again, but redirect the output to a file, this time:

    $ dropcaster > index.rss

If all went well, you will now have a valid podcast feed in your Dropbox, listing all mp3 files as podcast episodes. Please see the section [Publish Your Feed](#publish-your-feed) for details on how to find the public URL of your feed.

# Use Cases

## Publish a New Episode

1. Drop the mp3 file into the Dropbox Public folder (e.g. `~/Dropbox/Public`), and then run the following command in the directory where the mp3 files reside:

        $ dropcaster > index.rss

1. Dropbox will sync the updated index.rss file to its web server and any podcast client will download the new episode as soon as it has loaded the updated index.rss.

## Delete an Episode

Remove the mp3 you want to delete from the Dropbox Public folder, and then run the following command in the directory where the remaining mp3 files reside:

	  $ dropcaster > index.rss

## Replace an Episode With an Updated File

In the Dropbox Public folder, replace the mp3 you want to update with a new version, and then run the following command in the directory where the mp3 files reside:

	  $ dropcaster > index.rss

## Publish Your Feed

1. Re-generate the feed to make sure the it is up to date (see above):

        $ dropcaster > index.rss

1. In your Dropbox Public folder, right-click the index.rss and select "Dropbox / Copy public link". This copies the public, HTTP-addressable link to your podcast into the clipboard.
1. Publish this link and tell people to subscribe to it.

## Generate a Podcast Feed for a Subset of the Available MP3 Files

Dropcaster accepts any number of files or directories as episodes. For directories, all files ending in .mp3 will be included. For advanced filtering, you can use regular shell patterns to further specify which files will be included. These patterns will be resolved by the shell itself (e.g. bash), and not by Dropcaster.

For example, in order to generate a feed that only publishes MP3 files where the name starts with 'A', call Dropcaster like this:

    $ dropcaster A*.mp3 > index.rss

## Publish More than One Feed

	  $ dropcaster project1 > project1.rss
	  $ dropcaster project2 > project2.rss

or

	  $ cd project1
	  $ dropcaster > index.rss
	  $ cd ../project2
	  $ dropcaster > index.rss

## Include Episodes From Two Subdirectories Into a Single Feed

	  $ dropcaster project1 project2 > index.rss

# Advanced features

## Overriding defaults

Dropcaster is opinionated software. That means, it makes a number of assumptions about names, files, and directory structures. Dropcaster will be most simple to use if these assumptions and opinions apply to your way of using the program.

However, it is still possible to override Dropcaster's behavior in many ways. You can, for instance, host your episode files on a different URL than the channel. Instead of writing title, subtitle, etc. to a channel.yml, you may also spedify them on the command line.

In order to find out about all the options, simply run

        $ dropcaster --help

## Using custom channel templates

Dropcaster generates a feed that is suitable for most podcast clients, especially iTunes. By default, dropcaster follows [Apple's podcast specs / recommendations](http://www.apple.com/itunes/podcasts/specs.html).

It is also possible to customize the channel by supplying an alternative channel template on the command line. Start your own template by copying the default template, or look at the test directory of the dropcaster gem. You can get there by running `gem open dropcaster`.

## Generate a HTML page for your podcast

Besides generating an RSS feed, dropcaster can also generate HTML that can be used as a home page for your podcast. The template directory contains a sample template that can be used to get started:

        $ dropcaster --channel-template templates/channel.html.erb

As discussed above, the output of this command can be written to a file, too:

        $ dropcaster --channel-template templates/channel.html.erb > ~/Dropbox/Public/allabouteverything.html

Dropcaster works exactly the same, whether it generates an RSS feed or a HTML page. Therefore, all options discussed before also apply when generating HTML.

## Generate a HTML page for each episode

If the `--episode-pages` switch is present, dropcaster will generate a separate page for each episode. The result will not appear on STDOUT, but will be written to files that are named like he episode files, but with a file extension of `.html`.

For example, let's assume the following directory structure:

    channel.yml
    episodes/episode1/AAE001 Hello World.mp3
    episodes/episode2/AAE002 Getting started.mp3
    episodes/episode3/AAE003 Advanced Topics.mp3

With this directory structure, Dropcaster would typically be called like this:

    dropcaster episodes/episode* --channel channel.yml

In order to generate episode pages, the command would need to be modified to look as follows:

    dropcaster episodes/episode* --channel channel.yml --episode-pages

If any of the files to be generated already exist, Dropcaster will not overwrite them. Adding the `--force` option forces dropcaster to overwrite existing files.

The index.html page could be written with the same command by redirecting dropcaster's output to a file:

    dropcaster episodes/episode* --channel channel.yml --episode-pages --channel-template hannel.html.erb > index.html

As a result, each episode will get an HTML page next to the MP3 file. The default HTML channel template will write links pointing to each episode. After calling the example command above, the esulting directory structure would look like this:

        channel.yml
        index.html
        episodes/episode1/AAE001 Hello World.mp3
        episodes/episode1/AAE001 Hello World.html
        episodes/episode2/AAE002 Getting started.mp3
        episodes/episode2/AAE002 Getting started.html
        episodes/episode3/AAE003 Advanced Topics.mp3
        episodes/episode3/AAE003 Advanced Topics.html

Please note that the example above only deals with HTML pages. The RSS feed would still have to be generated with a second call to dropcaster (see the earlier sections of this page).

Dropcaster will use its default template for generating the episode pages. It is also possible to specify a custom episode template with the `--episode-template=FILE` switch, passing the name of a custom episode template file (similar to a custom channel template).

The major difference between the channel and episode HTML templates is that the episodes write out lyrics. For podcasts, lyrics are used for an in-depth description of the episode. Any text is treated as [Markdown](http://daringfireball.net/projects/markdown/) and converted to HTML.

## Sidecar files

You may override the meta data for any episode by providing a YAML file with the same name as the mp3 file, but with an extension of yml or yaml (ususally refered to as [sidecar file](http://en.wikipedia.org/wiki/Sidecar_file)). Any attributes specified in this file override the ID tags in the mp3 file.

Dropcaster will only write the sidecar file if the appropriate command line option was passed, and it will use the information in it only for generating new files like the index.rss. It will not write back to mp3 files.

Sidecar files are also useful for referencing a (remote) enclosure without re-hosting it (which, besides wasted bandwidth, could also create copyright issues). If a sidecar file is present and it points to a remote media URL, dropcaster will generate an item in the feed, even if the media is not available locally.

## A Note on iTunes

The generated XML file contains all elements required for iTunes. However, Dropcaster will not notify the iTunes store about new episodes.

## Using Dropcaster Without Dropbox

The whole concept of Dropcaster works perfectly fine without Dropbox. Just run the Dropcaster script in a directory of mp3 files and upload the files as well as the generated index.rss to a web server. Leave the relative position of the index and mp3 files as is, otherwise the path to the mp3 files in index.rss will become invalid.

## Episode Identifier (uuid)

Dropcaster uses a rather simple approach to uniquely identify the episodes. It simply generates a SHA1 hash of the mp3 file. If it changes, for whatever reason (even if only a tag was changed), the episode will get a new UUID, and any podcatcher will fetch the episode again (which is what you want, in most cases).

Modifying the sidecar file does not change the UUID, because it only affects the feed and not the episode itself.

## I Don't Like the Output Format that Dropcaster produces

Dropcaster uses an ERB template to generate the XML feed. The template was written so that it is easy to understand, but not necessarily in a way that would make the output rather nice-looking. That should not be an issue, as long as the XML is correct.

It you prefer a more aesthetically pleasing output, just pipe the output of Dropcaster through `xmllint`, which is part of [libxml](http://xmlsoft.org/):

    dropcaster | xmllint --format -

For writing the output to a file, just redirect the ouput of the above command:

    dropcaster | xmllint --format - > index.rss

# Web site

Dropcaster uses Steve Klabnik's [approach](https://github.com/steveklabnik/automatically_update_github_pages_with_travis_example) for publishing the site with [Travis CI](http://travis-ci.org/).

# Copyright

Copyright (c) 2011-2015 Nicolas E. Rabenau. See [LICENSE.txt](https://raw.github.com/nerab/dropcaster/master/LICENSE.txt) for further details.
