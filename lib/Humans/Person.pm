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
