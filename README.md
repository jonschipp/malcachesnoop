malcachesnoop
=============

Compare an updated malhost list to a DNS servers cache. <br>
Used to check internal DNS servers for signs of mal-ware on the network.

`malcachesnoop` downloads the latest [Mayhemic Labs](https://secure.mayhemiclabs.com/malhosts/malhosts.txt) list
and uses that to check for entries in a DNS server's cache looking for the presence of malware.

## Example:

```shell
./malcachesnoop 8.8.8.8
```

