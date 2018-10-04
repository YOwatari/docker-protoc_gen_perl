# docker-protoc_gen_perl
protoc for perl

## Example usage

```
$ mkdir -p lib
$ docker run --rm -v $(pwd):/tmp -w /tmp yowatari/protoc_gen_perl --perl-gpd_out=package=Humans.Person:lib person.proto
$ cat lib/Humans/Person.pm
package Humans::Person;

use strict;
use warnings;
use MIME::Base64 qw();
use Google::ProtocolBuffers::Dynamic;

my $gpd = Google::ProtocolBuffers::Dynamic->new;

$gpd->load_serialized_string(MIME::Base64::decode_base64(<<'EOD'));
CloKDHBlcnNvbi5wcm90bxIGaHVtYW5zIkIKBlBlcnNvbhISCgRuYW1lGAEgAigJUgRuYW1lEg4K
AmlkGAIgAigFUgJpZBIUCgVlbWFpbBgDIAEoCVIFZW1haWw=

EOD


$gpd->map(
    {
          'package' => 'humans',
                'prefix' => 'Humans::Person::Humans'
                    },
                    );

undef $gpd;

1;
```
