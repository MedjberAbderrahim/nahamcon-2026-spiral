# HackingHub CTF Creators Guide

For labs please avoid using docker-compose and just use Dockerfile, we run our labs as one lab per player so every player gets their own instance.

Avoid requiring arguments on the `docker build` process and put these into the Dockerfile instead.

Please create a separate GitHub repo per challenge and add the username `@BuildHackSecure` so we can access it.

### `brief.md`

This is just a small internal file to give us a brief overview of what the challenge will be. Please complete this ASAP.

### `settings.json`

`hh_username` = Your HackingHub username

`category` = Challenge type `binary`|`web`|`forensics`|`crypto`|`rev`|`pwn`|`misc`|`mobile`|`re`

`name` = Name of the challenge you wish to be displayed

`description` = A short description of the challenge no more than 125 characters

`difficulty` = 1 - 5 ( 1 = Easy / 5 = Toxic )

`answer_type` = flags|questions ( toggles whether to use flags.json or questions.json for answer format )

`lab` = Does the challenge contain a lab?

`http` = Is the lab http based or for example ssh

`port` = The port that will be exposed for the user to connect to

### `flags.json`

If `answer_type` is set to `flags` in `settings.json` we will use this file to populate the flags in the platform.

### `questions.json`

If `answer_type` is set to `questions` in `settings.json` we will use this file to populate the flags in the platform.

### `contents.md`

This contains the text you want to be displayed to the user when they enter your challenge, there's variables available inside this file.

{{ server-ip }} = The IP address of the challenge

{{ server-port }} = The port that the challenge is hosted on

{{ server-url }} = The random URL assigned to the challenge for HTTP for example https://d324wfdsdf2e.ctfio.com

### `downloads/`

Anything in this directory will get uploaded to our s3 bucket and made available for the ctf player to download

### `challenge/`

Place your challenge files i.e (Dockerfile) in here 

### `writeup.md`

Your complete writeup for how to complete the challenge, this will be shared once the contest is over