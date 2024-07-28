# Ubuntu mirror speed test

## Usage

Copy one of the commands below.

### Curl

```bash
curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/apt-speed.sh | bash
```

### Wget

```bash
wget -nv -O - https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/apt-speed.sh | bash
```

Open a terminal and run the script.

### Sample output
```
Testing SE mirrors for speed...

[1/7] http://ftp.acc.umu.se/ubuntu/ --> 5 KB/s
[2/7] http://mirror.zetup.net/ubuntu/ --> 1538 KB/s
[3/7] https://mirror.bahnhof.net/ubuntu/ --> 1010 KB/s
[4/7] https://ftpmirror1.infania.net/ubuntu/ --> 649 KB/s
[5/7] http://ftp.lysator.liu.se/ubuntu/ --> 699 KB/s
[6/7] http://ubuntu.mirror.su.se/ubuntu/ --> 961 KB/s
[7/7] http://archive.ubuntu.com/ubuntu/ --> 210 KB/s

Top 5 fastest mirrors

http://mirror.zetup.net/ubuntu/ 1538
https://mirror.bahnhof.net/ubuntu/ 1010
http://ubuntu.mirror.su.se/ubuntu/ 961
http://ftp.lysator.liu.se/ubuntu/ 699
https://ftpmirror1.infania.net/ubuntu/ 649
```

### Manual country code

Add an Alpha-2 country code as a parameter at the end of the command. 

Example for testing United Kingdom (country code `GB`) mirrors:

`curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/apt-speed.sh | bash -s GB`

List of available country codes: http://mirrors.ubuntu.com/

If none is provided, the script will select country to test by external IP GeoIP location from `ipinfo.io`.

## Recourses

- http://mirrors.ubuntu.com/
- https://launchpad.net/ubuntu/+archivemirrors

## Credit
Based on [Baeldung's curl Transfer Speed](https://www.baeldung.com/linux/apt-terminal-choose-fastest-mirror#3-curl-transfer-speed) script.