use strict;
use warnings;

use Test::More tests => 2;
use Test::NoWarnings;
use JSON::MaybeUTF8 qw(:v1);

use IO::Async::Loop;

use WebService::Async::Onfido;
use FindBin qw($Bin);

my $pid = fork();
die "fork error " unless defined($pid);
unless ($pid) {
    my $mock_server = "$Bin/../bin/mock_onfido.pl";
    open(STDOUT, '>/dev/null');
    open(STDERR, '>/dev/null');
    exec('perl', $mock_server, 'daemon');
}

sleep 1;
my $loop = IO::Async::Loop->new;
$loop->add(
    my $onfido = WebService::Async::Onfido->new(
        token    => 'test_token',
        base_uri => 'http://localhost:3000'
    ));

subtest 'validate document file' => sub {
    cmp_ok(scalar(@{$onfido->supported_documents_list()}), '==', scalar(@{decode_json_utf8(_get_supported_list())}));
    is_deeply($onfido->supported_documents_list(), decode_json_utf8(_get_supported_list()));
};

sub _get_supported_list {
    return <<'string_ending_delimiter';
    [
      {
        "country_name": "Afghanistan",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_code": "AFG"
      },
      {
        "country_grouping": "Africa",
        "country_code": "AGO",
        "country_name": "Angola",
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Anguilla",
        "country_code": "AIA",
        "country_grouping": "North America"
      },
      {
        "country_grouping": "Europe",
        "country_code": "ALB",
        "country_name": "Albania",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_name": "Andorra",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Europe",
        "country_code": "AND"
      },
      {
        "country_code": "ARE",
        "country_grouping": "Asia",
        "country_name": "United Arab Emirates",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Argentina",
        "country_grouping": "South America",
        "country_code": "ARG"
      },
      {
        "country_name": "Armenia",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_code": "ARM"
      },
      {
        "doc_types_list": [
          "Driving Licence"
        ],
        "country_name": "American Samoa",
        "country_grouping": "Australia",
        "country_code": "ASM"
      },
      {
        "country_name": "Antigua and Barbuda",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "North America",
        "country_code": "ATG"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Australia",
        "country_grouping": "Australia",
        "country_code": "AUS"
      },
      {
        "country_name": "Austria",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Visa",
          "Residence Permit"
        ],
        "country_grouping": "Europe",
        "country_code": "AUT"
      },
      {
        "country_name": "Azerbaijan",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_code": "AZE"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Burundi",
        "country_code": "BDI",
        "country_grouping": "Africa"
      },
      {
        "country_code": "BEL",
        "country_grouping": "Europe",
        "country_name": "Belgium",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "Residence Permit",
          "National Identity Card",
          "Visa",
          "Residence Permit (German)"
        ]
      },
      {
        "country_code": "BEN",
        "country_grouping": "Africa",
        "country_name": "Benin",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_grouping": "Africa",
        "country_code": "BFA",
        "country_name": "Burkina Faso",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "BGD",
        "country_grouping": "Asia",
        "country_name": "Bangladesh",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_code": "BGR",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_name": "Bulgaria"
      },
      {
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Bahrain",
        "country_code": "BHR",
        "country_grouping": "Asia"
      },
      {
        "country_code": "BHS",
        "country_grouping": "North America",
        "country_name": "Bahamas",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Bosnia and Herzegovina",
        "country_grouping": "Europe",
        "country_code": "BIH"
      },
      {
        "country_grouping": "North America",
        "country_code": "BLM",
        "doc_types_list": [
          "Driving Licence"
        ],
        "country_name": "Saint Barthelemy"
      },
      {
        "country_code": "BLR",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Passport",
          "Driving Licence"
        ],
        "country_name": "Belarus"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Belize",
        "country_code": "BLZ",
        "country_grouping": "North America"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Bermuda",
        "country_grouping": "North America",
        "country_code": "BMU"
      },
      {
        "country_code": "BOL",
        "country_grouping": "South America",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Bolivia (Plurinational State of)"
      },
      {
        "country_grouping": "South America",
        "country_code": "BRA",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card (RG Card)",
          "Passport"
        ],
        "country_name": "Brazil"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Barbados",
        "country_code": "BRB",
        "country_grouping": "North America"
      },
      {
        "country_code": "BRN",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Brunei Darussalam"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Bhutan",
        "country_code": "BTN",
        "country_grouping": "Asia"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Botswana",
        "country_code": "BWA",
        "country_grouping": "Africa"
      },
      {
        "country_name": "Central African Republic",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_code": "CAF"
      },
      {
        "country_name": "Canada",
        "doc_types_list": [
          "Driving Licence",
          "Visa",
          "National Health Insurance Card",
          "National Health Insurance Card (Health Card)",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_grouping": "North America",
        "country_code": "CAN"
      },
      {
        "country_code": "CHE",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ],
        "country_name": "Switzerland"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_name": "Chile",
        "country_code": "CHL",
        "country_grouping": "South America"
      },
      {
        "country_grouping": "Asia",
        "country_code": "CHN",
        "country_name": "China",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_code": "CIV",
        "country_grouping": "Africa",
        "country_name": "Cote d'Ivoire",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_name": "Cameroon",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_grouping": "Africa",
        "country_code": "CMR"
      },
      {
        "country_grouping": "Africa",
        "country_code": "COD",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Congo (The Democratic Republic of the)"
      },
      {
        "country_grouping": "Africa",
        "country_code": "COG",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Congo"
      },
      {
        "country_grouping": "South America",
        "country_code": "COL",
        "country_name": "Colombia",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "country_grouping": "Africa",
        "country_code": "COM",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Comoros"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Cabo Verde",
        "country_code": "CPV",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "North America",
        "country_code": "CRI",
        "country_name": "Costa Rica",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "country_grouping": "North America",
        "country_code": "CUB",
        "country_name": "Cuba",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_grouping": "North America",
        "country_code": "CYM",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Cayman Islands"
      },
      {
        "country_grouping": "Asia",
        "country_code": "CYP",
        "country_name": "Cyprus",
        "doc_types_list": [
          "Driving Licence (paper)",
          "Passport",
          "National Identity Card",
          "Driving Licence",
          "Residence Permit"
        ]
      },
      {
        "country_grouping": "Europe",
        "country_code": "CZE",
        "country_name": "Czechia",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "country_grouping": "Europe",
        "country_code": "DEU",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "Residence Permit",
          "National Identity Card",
          "Visa"
        ],
        "country_name": "Germany"
      },
      {
        "country_grouping": "Africa",
        "country_code": "DJI",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Djibouti"
      },
      {
        "country_code": "DMA",
        "country_grouping": "North America",
        "country_name": "Dominica",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "DNK",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Residence Permit",
          "Driving Licence",
          "Passport Card",
          "Passport",
          "Passport (faroe islands)",
          "Visa"
        ],
        "country_name": "Denmark"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Dominican Republic",
        "country_grouping": "North America",
        "country_code": "DOM"
      },
      {
        "country_name": "Algeria",
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ],
        "country_grouping": "Africa",
        "country_code": "DZA"
      },
      {
        "country_code": "ECU",
        "country_grouping": "South America",
        "country_name": "Ecuador",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_code": "EGY",
        "country_grouping": "Africa",
        "country_name": "Egypt",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_grouping": "Africa",
        "country_code": "ERI",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Eritrea"
      },
      {
        "country_name": "Spain",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport",
          "Residence Permit",
          "Visa"
        ],
        "country_code": "ESP",
        "country_grouping": "Europe"
      },
      {
        "country_name": "Estonia",
        "doc_types_list": [
          "Visa",
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_grouping": "Europe",
        "country_code": "EST"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_name": "Ethiopia",
        "country_code": "ETH",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "Europe",
        "country_code": "FIN",
        "country_name": "Finland",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "country_name": "Fiji",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Australia",
        "country_code": "FJI"
      },
      {
        "country_name": "France",
        "doc_types_list": [
          "Passport",
          "Residence Permit",
          "Driving Licence",
          "National Health Insurance Card (Carte Vitale)",
          "National Identity Card",
          "Visa"
        ],
        "country_grouping": "Europe",
        "country_code": "FRA"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Faroe Islands",
        "country_grouping": "Europe",
        "country_code": "FRO"
      },
      {
        "country_code": "FSM",
        "country_grouping": "Australia",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Micronesia (Federated States of)"
      },
      {
        "country_name": "Gabon",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_code": "GAB"
      },
      {
        "country_grouping": "Europe",
        "country_code": "GBR",
        "country_name": "United Kingdom of Great Britain and Northern Ireland",
        "doc_types_list": [
          "Certificate of Naturalisation",
          "Home Office Letter",
          "Immigration Status Document",
          "Asylum Registration Card",
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "country_grouping": "Asia",
        "country_code": "GEO",
        "country_name": "Georgia",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence"
        ],
        "country_name": "Guernsey",
        "country_grouping": "Europe",
        "country_code": "GGY"
      },
      {
        "country_code": "GHA",
        "country_grouping": "Africa",
        "country_name": "Ghana",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_grouping": "Europe",
        "country_code": "GIB",
        "country_name": "Gibraltar",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_grouping": "Africa",
        "country_code": "GIN",
        "country_name": "Guinea",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_grouping": "Africa",
        "country_code": "GMB",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Gambia"
      },
      {
        "country_name": "Guinea-Bissau",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "GNB",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "Africa",
        "country_code": "GNQ",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Equatorial Guinea"
      },
      {
        "country_grouping": "Europe",
        "country_code": "GRC",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Visa",
          "Residence Permit"
        ],
        "country_name": "Greece"
      },
      {
        "country_grouping": "North America",
        "country_code": "GRD",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Grenada"
      },
      {
        "country_grouping": "North America",
        "country_code": "GRL",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Greenland"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Guatemala",
        "country_code": "GTM",
        "country_grouping": "North America"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence"
        ],
        "country_name": "Guam",
        "country_grouping": "Australia",
        "country_code": "GUM"
      },
      {
        "country_code": "GUY",
        "country_grouping": "South America",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Guyana"
      },
      {
        "country_code": "HKG",
        "country_grouping": "Asia",
        "doc_types_list": [
          "National Identity Card (HKID)",
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Hong Kong"
      },
      {
        "country_name": "Honduras",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "HND",
        "country_grouping": "North America"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_name": "Croatia",
        "country_code": "HRV",
        "country_grouping": "Europe"
      },
      {
        "country_code": "HTI",
        "country_grouping": "North America",
        "country_name": "Haiti",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Hungary",
        "doc_types_list": [
          "Passport",
          "Residence Permit",
          "Driving Licence",
          "National Identity Card",
          "Visa"
        ],
        "country_code": "HUN",
        "country_grouping": "Europe"
      },
      {
        "country_name": "Indonesia",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ],
        "country_code": "IDN",
        "country_grouping": "Asia"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Isle of Man",
        "country_code": "IMN",
        "country_grouping": "Europe"
      },
      {
        "doc_types_list": [
          "Voter Id",
          "Tax Id (PAN Card)",
          "National Identity Card (Aadhaar Card)",
          "Passport"
        ],
        "country_name": "India",
        "country_code": "IND",
        "country_grouping": "Asia"
      },
      {
        "country_code": "IRL",
        "country_grouping": "Europe",
        "country_name": "Ireland",
        "doc_types_list": [
          "Driving Licence",
          "Passport Card",
          "Passport",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "country_grouping": "Asia",
        "country_code": "IRN",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Iran (Islamic Republic of)"
      },
      {
        "country_name": "Iraq",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "IRQ",
        "country_grouping": "Asia"
      },
      {
        "country_name": "Iceland",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "Visa"
        ],
        "country_grouping": "Europe",
        "country_code": "ISL"
      },
      {
        "country_name": "Israel",
        "doc_types_list": [
          "Passport",
          "Driving Licence"
        ],
        "country_grouping": "Asia",
        "country_code": "ISR"
      },
      {
        "country_name": "Italy",
        "doc_types_list": [
          "Driving Licence",
          "Visa",
          "National Identity Card",
          "Passport Card",
          "Passport",
          "Residence Permit"
        ],
        "country_code": "ITA",
        "country_grouping": "Europe"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Jamaica",
        "country_grouping": "North America",
        "country_code": "JAM"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Jersey",
        "country_grouping": "Europe",
        "country_code": "JEY"
      },
      {
        "country_grouping": "Asia",
        "country_code": "JOR",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Jordan"
      },
      {
        "country_code": "JPN",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Postal Identity Card (Juminhyo)",
          "Social Security Card (Individual Number Paper Slip)",
          "Driving Licence",
          "Passport",
          "National Identity Card (Individual Number Card)",
          "Residence Permit"
        ],
        "country_name": "Japan"
      },
      {
        "country_code": "KAZ",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Kazakhstan"
      },
      {
        "country_name": "Kenya",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_code": "KEN",
        "country_grouping": "Africa"
      },
      {
        "country_code": "KGZ",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Kyrgyzstan"
      },
      {
        "country_code": "KHM",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Cambodia"
      },
      {
        "country_name": "Kiribati",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Australia",
        "country_code": "KIR"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Saint Kitts and Nevis",
        "country_grouping": "North America",
        "country_code": "KNA"
      },
      {
        "country_grouping": "Asia",
        "country_code": "KOR",
        "doc_types_list": [
          "Passport",
          "National Identity Card",
          "Driving Licence"
        ],
        "country_name": "Korea, The Republic of"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Kuwait",
        "country_code": "KWT",
        "country_grouping": "Asia"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Lao People's Democratic Republic",
        "country_grouping": "Asia",
        "country_code": "LAO"
      },
      {
        "country_name": "Lebanon",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "LBN",
        "country_grouping": "Asia"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Liberia",
        "country_grouping": "Africa",
        "country_code": "LBR"
      },
      {
        "country_name": "Libya",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_code": "LBY"
      },
      {
        "country_code": "LCA",
        "country_grouping": "North America",
        "country_name": "Saint Lucia",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Liechtenstein",
        "doc_types_list": [
          "Visa",
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_grouping": "Europe",
        "country_code": "LIE"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Sri Lanka",
        "country_code": "LKA",
        "country_grouping": "Asia"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Lesotho",
        "country_grouping": "Africa",
        "country_code": "LSO"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Residence Permit",
          "Passport",
          "Visa"
        ],
        "country_name": "Lithuania",
        "country_grouping": "Europe",
        "country_code": "LTU"
      },
      {
        "country_name": "Luxembourg",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Visa",
          "Residence Permit"
        ],
        "country_grouping": "Europe",
        "country_code": "LUX"
      },
      {
        "country_code": "LVA",
        "country_grouping": "Europe",
        "country_name": "Latvia",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "country_code": "MAC",
        "country_grouping": "Asia",
        "country_name": "Macao",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "country_grouping": "North America",
        "country_code": "MAF",
        "country_name": "Saint Martin (French part)",
        "doc_types_list": [
          "Driving Licence"
        ]
      },
      {
        "country_code": "MAR",
        "country_grouping": "Africa",
        "country_name": "Morocco",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_name": "Monaco",
        "doc_types_list": [
          "Passport",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_code": "MCO",
        "country_grouping": "Europe"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_name": "Moldova, The Republic of",
        "country_grouping": "Europe",
        "country_code": "MDA"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Madagascar",
        "country_grouping": "Africa",
        "country_code": "MDG"
      },
      {
        "country_code": "MDV",
        "country_grouping": "Asia",
        "country_name": "Maldives",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Mexico",
        "doc_types_list": [
          "Voter Id (INE)",
          "Voter Id (IFE)",
          "Driving Licence",
          "Work Permit",
          "Passport"
        ],
        "country_grouping": "North America",
        "country_code": "MEX"
      },
      {
        "country_grouping": "Australia",
        "country_code": "MHL",
        "country_name": "Marshall Islands",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Macedonia, The former Yugoslav Republic of",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_code": "MKD",
        "country_grouping": "Europe"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Mali",
        "country_code": "MLI",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "Europe",
        "country_code": "MLT",
        "country_name": "Malta",
        "doc_types_list": [
          "Visa",
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Myanmar",
        "country_code": "MMR",
        "country_grouping": "Asia"
      },
      {
        "country_grouping": "Europe",
        "country_code": "MNE",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Montenegro"
      },
      {
        "country_code": "MNG",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Mongolia"
      },
      {
        "country_name": "Northern Mariana Islands",
        "doc_types_list": [
          "Driving Licence"
        ],
        "country_code": "MNP",
        "country_grouping": "Australia"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_name": "Mozambique",
        "country_code": "MOZ",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "North America",
        "country_code": "MSR",
        "country_name": "Montserrat",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Mauritius",
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ],
        "country_code": "MUS",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "Africa",
        "country_code": "MWI",
        "country_name": "Malawi",
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_grouping": "Asia",
        "country_code": "MYS",
        "country_name": "Malaysia",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card (MyKAD)",
          "National Identity Card (MyTentera)",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Namibia",
        "country_code": "NAM",
        "country_grouping": "Africa"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Niger",
        "country_code": "NER",
        "country_grouping": "Africa"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Voter Id",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Nigeria",
        "country_grouping": "Africa",
        "country_code": "NGA"
      },
      {
        "country_name": "Nicaragua",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "NIC",
        "country_grouping": "North America"
      },
      {
        "doc_types_list": [
          "Residence Permit",
          "Visa",
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Netherlands",
        "country_grouping": "Europe",
        "country_code": "NLD"
      },
      {
        "country_grouping": "Europe",
        "country_code": "NOR",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "Visa",
          "Residence Permit"
        ],
        "country_name": "Norway"
      },
      {
        "country_name": "Nepal",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_code": "NPL"
      },
      {
        "country_name": "Nauru",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "NRU",
        "country_grouping": "Australia"
      },
      {
        "country_code": "NZL",
        "country_grouping": "Australia",
        "doc_types_list": [
          "Passport",
          "Driving Licence"
        ],
        "country_name": "New Zealand"
      },
      {
        "country_code": "OMN",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Residence Permit",
          "Passport"
        ],
        "country_name": "Oman"
      },
      {
        "country_grouping": "Asia",
        "country_code": "PAK",
        "country_name": "Pakistan",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Panama",
        "country_code": "PAN",
        "country_grouping": "North America"
      },
      {
        "country_code": "PCN",
        "country_grouping": "Australia",
        "country_name": "Pitcairn",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Peru",
        "country_grouping": "South America",
        "country_code": "PER"
      },
      {
        "country_code": "PHL",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "Postal Identity Card",
          "Professional Qualification Card",
          "Social Security Card",
          "National Identity Card",
          "Voter Id",
          "Passport"
        ],
        "country_name": "Philippines"
      },
      {
        "country_name": "Palau",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "PLW",
        "country_grouping": "Australia"
      },
      {
        "country_grouping": "Australia",
        "country_code": "PNG",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Papua New Guinea"
      },
      {
        "country_grouping": "Europe",
        "country_code": "POL",
        "country_name": "Poland",
        "doc_types_list": [
          "National Identity Card",
          "Residence Permit",
          "Driving Licence",
          "Passport Card",
          "Passport",
          "Visa"
        ]
      },
      {
        "country_grouping": "North America",
        "country_code": "PRI",
        "country_name": "Puerto Rico",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card"
        ]
      },
      {
        "country_name": "Korea, The Democratic People's Republic of",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_code": "PRK"
      },
      {
        "country_name": "Portugal",
        "doc_types_list": [
          "Passport",
          "Visa",
          "Driving Licence",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_code": "PRT",
        "country_grouping": "Europe"
      },
      {
        "country_code": "PRY",
        "country_grouping": "South America",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Paraguay"
      },
      {
        "country_grouping": "Asia",
        "country_code": "PSE",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Palestine, State of"
      },
      {
        "doc_types_list": [
          "Driving Licence"
        ],
        "country_name": "French Polynesia",
        "country_grouping": "Australia",
        "country_code": "PYF"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Residence Permit",
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Qatar",
        "country_grouping": "Asia",
        "country_code": "QAT"
      },
      {
        "doc_types_list": [
          "Residence Permit",
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Romania",
        "country_code": "ROU",
        "country_grouping": "Europe"
      },
      {
        "country_name": "Russian Federation",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card (Internal Passport)"
        ],
        "country_grouping": "Europe",
        "country_code": "RUS"
      },
      {
        "country_name": "Rwanda",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_code": "RWA"
      },
      {
        "country_grouping": "Asia",
        "country_code": "SAU",
        "country_name": "Saudi Arabia",
        "doc_types_list": [
          "Driving Licence",
          "Residence Permit",
          "Passport"
        ]
      },
      {
        "country_grouping": "Africa",
        "country_code": "SDN",
        "country_name": "Sudan",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_grouping": "Africa",
        "country_code": "SEN",
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Senegal"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Work Permit (FIN card)",
          "National Identity Card (NRIC)",
          "Work Permit",
          "Work Permit (S Pass)",
          "Work Permit (Employment Pass)",
          "Passport"
        ],
        "country_name": "Singapore",
        "country_code": "SGP",
        "country_grouping": "Asia"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Solomon Islands",
        "country_grouping": "Australia",
        "country_code": "SLB"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Sierra Leone",
        "country_grouping": "Africa",
        "country_code": "SLE"
      },
      {
        "country_code": "SLV",
        "country_grouping": "North America",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "El Salvador"
      },
      {
        "country_name": "San Marino",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Europe",
        "country_code": "SMR"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Somalia",
        "country_code": "SOM",
        "country_grouping": "Africa"
      },
      {
        "country_name": "Serbia",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card"
        ],
        "country_code": "SRB",
        "country_grouping": "Europe"
      },
      {
        "country_grouping": "Africa",
        "country_code": "SSD",
        "country_name": "South Sudan",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Sao Tome and Principe",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "STP",
        "country_grouping": "Africa"
      },
      {
        "country_code": "SUR",
        "country_grouping": "South America",
        "country_name": "Suriname",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "SVK",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Driving Licence",
          "Visa",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_name": "Slovakia"
      },
      {
        "country_code": "SVN",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ],
        "country_name": "Slovenia"
      },
      {
        "country_code": "SWE",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Tax Id",
          "Visa",
          "Residence Permit"
        ],
        "country_name": "Sweden"
      },
      {
        "country_name": "Swaziland",
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ],
        "country_grouping": "Africa",
        "country_code": "SWZ"
      },
      {
        "country_name": "Seychelles",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "SYC",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "Asia",
        "country_code": "SYR",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Syrian Arab Republic"
      },
      {
        "country_grouping": "North America",
        "country_code": "TCA",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Turks and Caicos Islands"
      },
      {
        "country_name": "Chad",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "TCD",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "Africa",
        "country_code": "TGO",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Togo"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Thailand",
        "country_grouping": "Asia",
        "country_code": "THA"
      },
      {
        "country_name": "Tajikistan",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_code": "TJK"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Turkmenistan",
        "country_grouping": "Asia",
        "country_code": "TKM"
      },
      {
        "country_code": "TON",
        "country_grouping": "Australia",
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Tonga"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Trinidad and Tobago",
        "country_grouping": "North America",
        "country_code": "TTO"
      },
      {
        "country_name": "Tunisia",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_code": "TUN",
        "country_grouping": "Africa"
      },
      {
        "country_code": "TUR",
        "country_grouping": "Europe",
        "country_name": "Turkey",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Residence Permit",
          "Passport"
        ]
      },
      {
        "country_name": "Tuvalu",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "TUV",
        "country_grouping": "Australia"
      },
      {
        "country_code": "TWN",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_name": "Taiwan (Province of China)"
      },
      {
        "country_name": "Tanzania, United Republic of",
        "doc_types_list": [
          "Driving Licence",
          "Voter Id",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_code": "TZA",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "Africa",
        "country_code": "UGA",
        "country_name": "Uganda",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_grouping": "Europe",
        "country_code": "UKR",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card"
        ],
        "country_name": "Ukraine"
      },
      {
        "country_name": "Uruguay",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ],
        "country_code": "URY",
        "country_grouping": "South America"
      },
      {
        "doc_types_list": [
          "National Identity Card (State Identity Card) (State ID)",
          "Driving Licence",
          "National Identity Card (State ID)",
          "Residence Permit (Green Card)",
          "National Identity Card (Real ID ) (State ID)",
          "Driving Licence (Enhanced)",
          "Work Permit",
          "Passport Card",
          "Passport",
          "Visa",
          "Driving Licence (Vertical )",
          "Driving Licence (Intermediate)"
        ],
        "country_name": "United States of America",
        "country_code": "USA",
        "country_grouping": "North America"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Uzbekistan",
        "country_grouping": "Asia",
        "country_code": "UZB"
      },
      {
        "country_name": "Holy See",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "VAT",
        "country_grouping": "Europe"
      },
      {
        "country_grouping": "North America",
        "country_code": "VCT",
        "country_name": "Saint Vincent and the Grenadines",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Venezuela (Bolivarian Republic of)",
        "country_grouping": "South America",
        "country_code": "VEN"
      },
      {
        "country_name": "Virgin Islands (British)",
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "VGB",
        "country_grouping": "North America"
      },
      {
        "country_code": "VIR",
        "country_grouping": "North America",
        "country_name": "Virgin Islands (U.S.)",
        "doc_types_list": [
          "National Identity Card"
        ]
      },
      {
        "country_grouping": "Asia",
        "country_code": "VNM",
        "country_name": "Viet Nam",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_code": "VUT",
        "country_grouping": "Australia",
        "country_name": "Vanuatu",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Samoa",
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Australia",
        "country_code": "WSM"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "Passport (Overseas )"
        ],
        "country_name": "Yemen",
        "country_grouping": "Asia",
        "country_code": "YEM"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "South Africa",
        "country_grouping": "Africa",
        "country_code": "ZAF"
      },
      {
        "country_name": "Zambia",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_code": "ZMB"
      },
      {
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Zimbabwe",
        "country_code": "ZWE",
        "country_grouping": "Africa"
      }
    ]
string_ending_delimiter
}

kill('TERM', $pid);
