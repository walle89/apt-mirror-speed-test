# APT Mirror Speed Test

Performs speed and latency testing of Ubuntu and Debian mirrors.

## System requirements

This script is designed for internet-connected Linux-based systems with Curl installed.

## Ubuntu

Mirror list sources:
- http://mirrors.ubuntu.com/
- https://launchpad.net/ubuntu/+archivemirrors

### Usage

To test Ubuntu mirrors, copy and execute one of the following commands:

```bash
curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash
```
or

```bash
wget -nv -O - https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash
```

This will automatically select the country for testing based on the IP address of the device running the script’s GeoIP location.

If no country code is provided, the script will select the country to test based on the external IP GeoIP location from ipinfo.io.

### Manual country code (optional)

You can specify a country code (Alpha-2) as a parameter to test mirrors in that specific country. 

For example, to test United Kingdom mirrors (country code GB):

`curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash -s GB`

List of available country codes: http://mirrors.ubuntu.com/.

### Test all mirrors

To test all mirrors listed on [Launchpad](https://launchpad.net/ubuntu/+archivemirrors), use the following command with `ALL`:

`curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash -s ALL`

### Sample output

```
Testing SE mirrors for speed...

[1/7] https://ftpmirror1.infania.net/ubuntu/ --> 1298 KB/s -  ms
[2/7] http://ftp.acc.umu.se/ubuntu/ --> 8 KB/s - 19.895 ms
[3/7] https://mirror.bahnhof.net/ubuntu/ --> 1000 KB/s - 12.575 ms
[4/7] http://ftp.lysator.liu.se/ubuntu/ --> 1219 KB/s - 15.141 ms
[5/7] http://ubuntu.mirror.su.se/ubuntu/ --> 1538 KB/s - 12.280 ms
[6/7] http://mirror.zetup.net/ubuntu/ --> 2564 KB/s - 7.295 ms
[7/7] http://archive.ubuntu.com/ubuntu/ --> 793 KB/s - 23.976 ms

Top 5 fastest mirrors

http://mirror.zetup.net/ubuntu/ 2564 7.295
http://ubuntu.mirror.su.se/ubuntu/ 1538 12.280
https://ftpmirror1.infania.net/ubuntu/ 1298
http://ftp.lysator.liu.se/ubuntu/ 1219 15.141
https://mirror.bahnhof.net/ubuntu/ 1000 12.575
```

## Debian

Mirror list source: https://www.debian.org/mirror/list-full.

### Usage

To test Debian mirrors, copy and execute one of the following commands:

```bash
curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/debian-apt-speed.sh | bash
```

or

```bash
wget -nv -O - https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/debian-apt-speed.sh | bash
```

### Sample output

```
Testing mirrors for speed...

[1/327] http://mirrors.asnet.am/debian/ --> 211 KB/s -  ms
[2/327] http://ftp.am.debian.org/debian/ --> 253 KB/s -  ms
[3/327] http://debian.unnoba.edu.ar/debian/ --> 52 KB/s - 211.217 ms
[4/327] http://ftp.tu-graz.ac.at/mirror/debian/ --> 382 KB/s -  ms
[5/327] http://debian.anexia.at/debian/ --> 638 KB/s - 27.363 ms
[6/327] http://debian.lagis.at/debian/ --> 372 KB/s - 33.781 ms
[7/327] http://debian.mur.at/debian/ --> 187 KB/s -  ms
[8/327] http://debian.sil.at/debian/ --> 427 KB/s - 28.483 ms
[9/327] http://mirror.alwyzon.net/debian/ --> 488 KB/s - 26.552 ms
...
[327/327] http://ftp.is.co.za/debian/ --> 0 KB/s - 169.425 ms

Top 5 fastest mirrors

http://mirror.zetup.net/debian/ 2083 7.407
http://mirrors.rackhosting.com/debian/ 1612 6.616
http://artfiles.org/debian/ 1428 11.669
http://mirror.one.com/debian/ 1250 6.184
http://mirror.wtnet.de/debian/ 1219 11.088
```

## Credit

Based on the [Baeldung's curl Transfer Speed](https://www.baeldung.com/linux/apt-terminal-choose-fastest-mirror#3-curl-transfer-speed) script.