#!/bin/bash

password=""

echo -n 'password: ' && read -s password

export password
perl -e 'my @chars = (0..9, 'A'..'Z', 'a'..'z'); my $salt = "\$6\$"; $salt .= $chars[rand @chars] for 1..16; print crypt($ENV{"password"}, $salt) . "\n";'
