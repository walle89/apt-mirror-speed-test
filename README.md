# Ubuntu mirror speed test

Speed and latency testing of Ubuntu mirrors.

## Ubuntu

### Usage

Copy one of the commands below.

#### Curl

```bash
curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash
```

#### Wget

```bash
wget -nv -O - https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash
```

Open a terminal and run the script.

#### Sample output

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

#### Manual country code

Add an Alpha-2 country code as a parameter at the end of the command. 

Example for testing United Kingdom (country code `GB`) mirrors:

`curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash -s GB`

List of available country codes: http://mirrors.ubuntu.com/

If none is provided, the script will select country to test by external IP GeoIP location from `ipinfo.io`.

#### Test all mirrors

To test all mirrors listed on [Launchpad](https://launchpad.net/ubuntu/+archivemirrors), add `ALL` as a parameter at the end of the command.

`curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash -s ALL`

## Recourses

- http://mirrors.ubuntu.com/
- https://launchpad.net/ubuntu/+archivemirrors

## Credit

Based on [Baeldung's curl Transfer Speed](https://www.baeldung.com/linux/apt-terminal-choose-fastest-mirror#3-curl-transfer-speed) script.