# Dropcaster - Simple Podcast Publishing

[![Build Status](https://travis-ci.org/nerab/dropcaster.png?branch=master)](https://travis-ci.org/nerab/dropcaster)

  _This project is developed with the [readme-driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) method. This file describes the functionality that is actually implemented, whereas the [vision](VISION.markdown) reflects where the tool should go._

[Dropcaster](http://nerab.github.io/dropcaster/) is a podcast feed generator for the command line. It  works with any (static file) web hoster.

Author: Nicolas E. Rabenau <nerab@gmx.at>

# What is the problem that Dropcaster is trying to solve?

You have a number of podcast episodes that you would like to publish as a feed. Nothing else - no fancy website, no stats, nothing but the pure podcast.

With Dropcaster, you simply put the mp3 files into the `public_html` folder of your web host. Then run `dropcaster` - it generates the feed and writes it to a file, e.g. `index.rss`. You can then take the RSS file's URL and publish it as the feed URL.

The feed URL can be consumed by any podcatcher, e.g. [iTunes](http://www.apple.com/itunes/) or [Juice](http://juicereceiver.sourceforge.net/).

# Installation

## As a Ruby Gem

```command
$ gem install dropcaster
$ dropcaster --help
```

`libxml-ruby` is a frequent offender with installation problems. As usual, [Stack Overflow](https://stackoverflow.com/questions/38129330/libxml-ruby-failed-to-build-gem-native-extension#comment98572516_55162900) has the answer (at least for macOS with Homebrew):

```command
$ gem install --no-document libxml-ruby -- --with-xml2-config="$(brew --prefix libxml2)/bin/xml2-config"
```

## Docker

If you prefer Docker over a local installation, use

```command
$ docker run -it --rm nerab/dropcaster dropcaster --help
```

The container will need access to the mp3 files on your workstation [with a bind mount](https://docs.docker.com/storage/bind-mounts/). For instance, running `dropcaster` with the [test fixtures](test/fixtures) will look like this:

```command
$ docker \
    run \
      -it \
      --rm \
      --mount type=bind,source="$(pwd)"/test/fixtures,target=/public_html \
    nerab/dropcaster
```

Replace `"$(pwd)"/test/fixtures` with your own folder of mp3s, and you can run the command above without even installing Ruby.

# Basic Usage

Once Dropcaster is installed, the only two other things you will need are a channel definition and one or more mp3 files to publish.

Let's start with the channel definition. It is a simple [YAML](http://yaml.org/) file that holds the general information about your podcast channel. According to the [RSS 2.0 spec](http://blogs.law.harvard.edu/tech/rss#requiredChannelElements), the only mandatory information that your channel absolutely needs are a title, a description and a link to a web site where the channel belongs to.

The simplest channel file looks like this:

```yaml
:title: 'All About Everything'
:description: 'A show about everything'
:url: 'http://www.example.com/podcasts/everything/index.html'
```

Store this file as channel.yml in the same directory where the mp3 files of your podcast reside. The channel definition is expected to be present in the same directory as your mp3 files, but this can be overridden using a command line switch. You can find a [more elaborate example](http://github.com/nerab/dropcaster/blob/master/doc/sample-channel.yml) for the channel definition in the doc folder of the Dropcaster gem. You can find it by running `gem open dropcaster`.

Now that we have the podcast channel defined, we need at least one episode (an audio file) in it. From Dropcaster's perspective, it does not matter how the episode was produced, but the critical information is the meta data in the mp3 file, because that is the authoritative source for the episode information. Almost all audio editors can write metadata, usually called ID3 tags. Dropcaster reads these tags from the mp3 files and fills the item element in the feed (that's how an episode is defined, technically) from it.

With all required pieces in place, we could generate the podcast feed. Just before we do that, we will inspect the feed by running the following commands:

```command
$ cd ~/public_html
$ dropcaster
```

(The above lines assume that `public_html` is the web server's document root, and that there is at least one mp3 file in `public_html`).

Dropcaster will print the feed to standard-out, without writing it to disk. When you are happy with the results, call Dropcaster again, but redirect the output to a file, this time:

```command
$ dropcaster > index.rss
```

If all went well, you will now have a valid podcast feed in `public_html`, listing all mp3 files as podcast episodes. Please see the section [Publish Your Feed](#publish-your-feed) for details on how to find the public URL of your feed.

# Use Cases

## Publish a New Episode

1. Drop the mp3 file into the `public_html` folder, and then run the following command in that directory:

   ```command
   $ dropcaster > index.rss
   ```

1. Sync the updated index.rss file to the public web server, and any podcast client will download the new episode as soon as it has loaded the updated index.rss.

## Delete an Episode

1. Remove the mp3 you want to delete from the `public_html` folder, and then run the following command in the directory where the remaining mp3 files reside:

   ```command
   $ dropcaster > index.rss
   ```

1. Sync the updated index.rss file to the public web server. Podcast clients will no longer download the removed episode.

## Replace an Episode With an Updated File

1. In the `public_html` folder, replace the mp3 you want to update with a new version, and then run the following command in the directory where the mp3 files reside:

   ```command
   $ dropcaster > index.rss
   ```

1. Sync the updated index.rss file to the public web server. Podcast clients detect the change and download the updated episode.

## Generate a Podcast Feed for a Subset of the Available MP3 Files

Dropcaster accepts any number of files or directories as episodes. For directories, all files ending in .mp3 will be included. For advanced filtering, you can use regular shell patterns to further specify which files will be included. These patterns will be resolved by the shell itself (e.g. bash), and not by Dropcaster.

For example, in order to generate a feed that only publishes MP3 files where the name starts with 'A', call Dropcaster like this:

```command
$ dropcaster A*.mp3 > index.rss
```

## Publish More than One Feed

```command
$ dropcaster project1 > project1.rss
$ dropcaster project2 > project2.rss
```

or

```command
$ cd project1
$ dropcaster > index.rss
$ cd ../project2
$ dropcaster > index.rss
```

## Include Episodes From Two Subdirectories Into a Single Feed

```command
$ dropcaster project1 project2 > index.rss
```

# Advanced features

## Overriding defaults

Dropcaster is opinionated software. That means, it makes a number of assumptions about names, files, and directory structures. Dropcaster will be most simple to use if these assumptions and opinions apply to your way of using the program.

However, it is still possible to override Dropcaster's behavior in many ways. You can, for instance, host your episode files on a different URL than the channel. Instead of writing title, subtitle, etc. to a channel.yml, you may also spedify them on the command line.

In order to find out about all the options, simply run

```command
$ dropcaster --help
```

## Using custom channel templates

Dropcaster generates a feed that is suitable for most podcast clients, especially iTunes. By default, dropcaster follows [Apple's podcast specs / recommendations](http://www.apple.com/itunes/podcasts/specs.html).

It is also possible to customize the channel by supplying an alternative channel template on the command line. Start your own template by copying the default template, or look at the test directory of the dropcaster gem. You can get there by running `gem open dropcaster`.

## Generate a HTML page for your podcast

Besides generating an RSS feed, dropcaster can also generate HTML that can be used as a home page for your podcast. The template directory contains a sample template that can be used to get started:

```
$ dropcaster --channel-template templates/channel.html.erb
```

As discussed above, the output of this command can be written to a file, too:

```command
$ dropcaster --channel-template templates/channel.html.erb > ~/public_html/allabouteverything.html
```

Dropcaster works exactly the same, whether it generates an RSS feed or a HTML page. Therefore, all options discussed before also apply when generating HTML.

## A Note on iTunes

The generated XML file contains all elements required for iTunes. However, Dropcaster will not notify the iTunes store about new episodes.

## Using Dropcaster With S3 or Digital Ocean Spaces

If you set up an S3 bucket or Digital Ocean Space (or any other s3 compatible static asset host), you can easily sync your local podcast directory using a command line tool like [s3cmd](https://github.com/s3tools/s3cmd).

After installing s3cmd, make sure you have the right credentials to write to your bucket/space. Add your mp3 files to your folder, run `dropcaster > index.rss` and then `s3cmd sync  ./  s3://$your-bucket-name --acl public-read`. S3cmd will now upload any new or changed files to your bucket.

## Episode Identifier (uuid)

Dropcaster uses a rather simple approach to uniquely identify the episodes. It simply generates a SHA1 hash of the mp3 file. If it changes, for whatever reason (even if only a tag was changed), the episode will get a new UUID, and any podcatcher will fetch the episode again (which is what you want, in most cases).

## I Don't Like the Output Format that Dropcaster produces

Dropcaster uses an ERB template to generate the XML feed. The template was written so that it is easy to understand, but not necessarily in a way that would make the output rather nice-looking. That should not be an issue, as long as the XML is correct.

It you prefer a more aesthetically pleasing output, just pipe the output of Dropcaster through `xmllint`, which is part of [libxml](http://xmlsoft.org/):

```command
$ dropcaster | xmllint --format -
```

For writing the output to a file, just redirect the ouput of the above command:

```command
$ dropcaster | xmllint --format - > index.rss
```

# Web site

Dropcaster uses Steve Klabnik's [approach](https://github.com/steveklabnik/automatically_update_github_pages_with_travis_example) for publishing the site with [Travis CI](http://travis-ci.org/).

# Copyright

Copyright (c) 2011-2021 Nicolas E. Rabenau. See [LICENSE.txt](https://raw.github.com/nerab/dropcaster/master/LICENSE.txt) for further details.
