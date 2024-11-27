install hash in the .ini files are generated from the firefox installation path,
encoded into utf16 and then passed through cityhash64 to get the hash.

for some general hashes you can consult this comment:
https://github.com/twpayne/chezmoi/issues/1226#issuecomment-867228095

as well as this tool to generate the hashes:
https://github.com/bradenhilton/mozillainstallhash/blob/main/mozillainstallhash.go