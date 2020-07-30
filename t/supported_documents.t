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
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "AFG",
        "country_grouping": "Asia",
        "country_name": "Afghanistan"
      },
      {
        "country_code": "AGO",
        "country_name": "Angola",
        "country_grouping": "Africa",
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_code": "AIA",
        "country_grouping": "Americas",
        "country_name": "Anguilla",
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
        "country_name": "Albania",
        "country_grouping": "Europe",
        "country_code": "ALB"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_code": "AND",
        "country_name": "Andorra",
        "country_grouping": "Europe"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_grouping": "Asia",
        "country_name": "United Arab Emirates",
        "country_code": "ARE"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_grouping": "Americas",
        "country_name": "Argentina",
        "country_code": "ARG"
      },
      {
        "country_code": "ARM",
        "country_name": "Armenia",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence"
        ],
        "country_code": "ASM",
        "country_name": "American Samoa",
        "country_grouping": "Oceania"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Americas",
        "country_name": "Antigua and Barbuda",
        "country_code": "ATG"
      },
      {
        "country_code": "AUS",
        "country_name": "Australia",
        "country_grouping": "Oceania",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_name": "Austria",
        "country_grouping": "Europe",
        "country_code": "AUT",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_name": "Azerbaijan",
        "country_code": "AZE"
      },
      {
        "country_code": "BDI",
        "country_name": "Burundi",
        "country_grouping": "Africa",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "Residence Permit",
          "National Identity Card",
          "Visa",
          "Residence Permit (German)"
        ],
        "country_code": "BEL",
        "country_grouping": "Europe",
        "country_name": "Belgium"
      },
      {
        "country_code": "BEN",
        "country_name": "Benin",
        "country_grouping": "Africa",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "BFA",
        "country_grouping": "Africa",
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
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_code": "BGR",
        "country_name": "Bulgaria",
        "country_grouping": "Europe"
      },
      {
        "country_name": "Bahrain",
        "country_grouping": "Asia",
        "country_code": "BHR",
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_name": "Bahamas",
        "country_grouping": "Americas",
        "country_code": "BHS",
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
        "country_code": "BIH",
        "country_grouping": "Europe",
        "country_name": "Bosnia and Herzegovina"
      },
      {
        "country_grouping": "Americas",
        "country_name": "Saint Barthelemy",
        "country_code": "BLM",
        "doc_types_list": [
          "Driving Licence"
        ]
      },
      {
        "doc_types_list": [
          "Passport",
          "Driving Licence"
        ],
        "country_name": "Belarus",
        "country_grouping": "Europe",
        "country_code": "BLR"
      },
      {
        "country_code": "BLZ",
        "country_name": "Belize",
        "country_grouping": "Americas",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "BMU",
        "country_name": "Bermuda",
        "country_grouping": "Americas",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_code": "BOL",
        "country_name": "Bolivia (Plurinational State of)",
        "country_grouping": "Americas"
      },
      {
        "country_grouping": "Americas",
        "country_name": "Brazil",
        "country_code": "BRA",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card (RG Card)",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_code": "BRB",
        "country_grouping": "Americas",
        "country_name": "Barbados"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Brunei Darussalam",
        "country_grouping": "Asia",
        "country_code": "BRN"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "BTN",
        "country_name": "Bhutan",
        "country_grouping": "Asia"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Botswana",
        "country_grouping": "Africa",
        "country_code": "BWA"
      },
      {
        "country_name": "Central African Republic",
        "country_grouping": "Africa",
        "country_code": "CAF",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Visa",
          "National Health Insurance Card",
          "National Health Insurance Card (Health Card)",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_grouping": "Americas",
        "country_name": "Canada",
        "country_code": "CAN"
      },
      {
        "country_grouping": "Europe",
        "country_name": "Switzerland",
        "country_code": "CHE",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "country_code": "CHL",
        "country_name": "Chile",
        "country_grouping": "Americas",
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
          "National Identity Card",
          "Passport"
        ],
        "country_code": "CHN",
        "country_name": "China",
        "country_grouping": "Asia"
      },
      {
        "country_name": "Cote d'Ivoire",
        "country_grouping": "Africa",
        "country_code": "CIV",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_name": "Cameroon",
        "country_grouping": "Africa",
        "country_code": "CMR",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "COD",
        "country_name": "Congo (The Democratic Republic of the)",
        "country_grouping": "Africa"
      },
      {
        "country_name": "Congo",
        "country_grouping": "Africa",
        "country_code": "COG",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Colombia",
        "country_grouping": "Americas",
        "country_code": "COL",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Comoros",
        "country_grouping": "Africa",
        "country_code": "COM"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "CPV",
        "country_grouping": "Africa",
        "country_name": "Cabo Verde"
      },
      {
        "country_name": "Costa Rica",
        "country_grouping": "Americas",
        "country_code": "CRI",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "country_grouping": "Americas",
        "country_name": "Cuba",
        "country_code": "CUB",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "CYM",
        "country_name": "Cayman Islands",
        "country_grouping": "Americas"
      },
      {
        "country_code": "CYP",
        "country_grouping": "Asia",
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
        "country_name": "Czechia",
        "country_code": "CZE",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "Residence Permit",
          "National Identity Card",
          "Visa"
        ],
        "country_name": "Germany",
        "country_grouping": "Europe",
        "country_code": "DEU"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "DJI",
        "country_grouping": "Africa",
        "country_name": "Djibouti"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "DMA",
        "country_name": "Dominica",
        "country_grouping": "Americas"
      },
      {
        "country_code": "DNK",
        "country_name": "Denmark",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Residence Permit",
          "Driving Licence",
          "Passport Card",
          "Passport",
          "Passport (faroe islands)",
          "Visa"
        ]
      },
      {
        "country_code": "DOM",
        "country_grouping": "Americas",
        "country_name": "Dominican Republic",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Algeria",
        "country_grouping": "Africa",
        "country_code": "DZA"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Ecuador",
        "country_grouping": "Americas",
        "country_code": "ECU"
      },
      {
        "country_grouping": "Africa",
        "country_name": "Egypt",
        "country_code": "EGY",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_name": "Eritrea",
        "country_code": "ERI"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport",
          "Residence Permit",
          "Visa"
        ],
        "country_grouping": "Europe",
        "country_name": "Spain",
        "country_code": "ESP"
      },
      {
        "country_code": "EST",
        "country_grouping": "Europe",
        "country_name": "Estonia",
        "doc_types_list": [
          "Visa",
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_code": "ETH",
        "country_grouping": "Africa",
        "country_name": "Ethiopia"
      },
      {
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ],
        "country_code": "FIN",
        "country_name": "Finland",
        "country_grouping": "Europe"
      },
      {
        "country_code": "FJI",
        "country_name": "Fiji",
        "country_grouping": "Oceania",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_code": "FRA",
        "country_name": "France",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Passport",
          "Residence Permit",
          "Driving Licence",
          "National Health Insurance Card (Carte Vitale)",
          "National Identity Card",
          "Visa"
        ]
      },
      {
        "country_code": "FRO",
        "country_grouping": "Europe",
        "country_name": "Faroe Islands",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_grouping": "Oceania",
        "country_name": "Micronesia (Federated States of)",
        "country_code": "FSM",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "GAB",
        "country_grouping": "Africa",
        "country_name": "Gabon"
      },
      {
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
        ],
        "country_name": "United Kingdom of Great Britain and Northern Ireland",
        "country_grouping": "Europe",
        "country_code": "GBR"
      },
      {
        "country_code": "GEO",
        "country_name": "Georgia",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card"
        ]
      },
      {
        "country_name": "Guernsey",
        "country_grouping": "Europe",
        "country_code": "GGY",
        "doc_types_list": [
          "Driving Licence"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Ghana",
        "country_grouping": "Africa",
        "country_code": "GHA"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_code": "GIB",
        "country_grouping": "Europe",
        "country_name": "Gibraltar"
      },
      {
        "country_name": "Guinea",
        "country_grouping": "Africa",
        "country_code": "GIN",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "GMB",
        "country_name": "Gambia",
        "country_grouping": "Africa"
      },
      {
        "country_code": "GNB",
        "country_name": "Guinea-Bissau",
        "country_grouping": "Africa",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_name": "Equatorial Guinea",
        "country_code": "GNQ"
      },
      {
        "country_name": "Greece",
        "country_grouping": "Europe",
        "country_code": "GRC",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "GRD",
        "country_name": "Grenada",
        "country_grouping": "Americas"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "GRL",
        "country_name": "Greenland",
        "country_grouping": "Americas"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Guatemala",
        "country_grouping": "Americas",
        "country_code": "GTM"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence"
        ],
        "country_code": "GUM",
        "country_grouping": "Oceania",
        "country_name": "Guam"
      },
      {
        "country_name": "Guyana",
        "country_grouping": "Americas",
        "country_code": "GUY",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card (HKID)",
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Hong Kong",
        "country_grouping": "Asia",
        "country_code": "HKG"
      },
      {
        "country_code": "HND",
        "country_grouping": "Americas",
        "country_name": "Honduras",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_code": "HRV",
        "country_name": "Croatia",
        "country_grouping": "Europe"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "HTI",
        "country_grouping": "Americas",
        "country_name": "Haiti"
      },
      {
        "doc_types_list": [
          "Passport",
          "Residence Permit",
          "Driving Licence",
          "National Identity Card",
          "Visa"
        ],
        "country_code": "HUN",
        "country_grouping": "Europe",
        "country_name": "Hungary"
      },
      {
        "country_name": "Indonesia",
        "country_grouping": "Asia",
        "country_code": "IDN",
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
        "country_code": "IMN",
        "country_name": "Isle of Man",
        "country_grouping": "Europe"
      },
      {
        "country_grouping": "Asia",
        "country_name": "India",
        "country_code": "IND",
        "doc_types_list": [
          "Voter Id",
          "Tax Id (PAN Card)",
          "National Identity Card (Aadhaar Card)",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport Card",
          "Passport",
          "Visa",
          "Residence Permit"
        ],
        "country_code": "IRL",
        "country_grouping": "Europe",
        "country_name": "Ireland"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "IRN",
        "country_name": "Iran (Islamic Republic of)",
        "country_grouping": "Asia"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Iraq",
        "country_grouping": "Asia",
        "country_code": "IRQ"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "Visa"
        ],
        "country_name": "Iceland",
        "country_grouping": "Europe",
        "country_code": "ISL"
      },
      {
        "doc_types_list": [
          "Passport",
          "Driving Licence"
        ],
        "country_name": "Israel",
        "country_grouping": "Asia",
        "country_code": "ISR"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Visa",
          "National Identity Card",
          "Passport Card",
          "Passport",
          "Residence Permit"
        ],
        "country_code": "ITA",
        "country_name": "Italy",
        "country_grouping": "Europe"
      },
      {
        "country_code": "JAM",
        "country_grouping": "Americas",
        "country_name": "Jamaica",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Europe",
        "country_name": "Jersey",
        "country_code": "JEY"
      },
      {
        "country_name": "Jordan",
        "country_grouping": "Asia",
        "country_code": "JOR",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_code": "JPN",
        "country_grouping": "Asia",
        "country_name": "Japan",
        "doc_types_list": [
          "Postal Identity Card (Juminhyo)",
          "Social Security Card (Individual Number Paper Slip)",
          "Driving Licence",
          "Passport",
          "National Identity Card (Individual Number Card)",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_name": "Kazakhstan",
        "country_code": "KAZ"
      },
      {
        "country_name": "Kenya",
        "country_grouping": "Africa",
        "country_code": "KEN",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_code": "KGZ",
        "country_name": "Kyrgyzstan",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "KHM",
        "country_name": "Cambodia",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "KIR",
        "country_grouping": "Oceania",
        "country_name": "Kiribati"
      },
      {
        "country_code": "KNA",
        "country_name": "Saint Kitts and Nevis",
        "country_grouping": "Americas",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_grouping": "Asia",
        "country_name": "Korea, The Republic of",
        "country_code": "KOR",
        "doc_types_list": [
          "Passport",
          "National Identity Card",
          "Driving Licence"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "Kuwait",
        "country_grouping": "Asia",
        "country_code": "KWT"
      },
      {
        "country_grouping": "Asia",
        "country_name": "Lao People's Democratic Republic",
        "country_code": "LAO",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Lebanon",
        "country_grouping": "Asia",
        "country_code": "LBN"
      },
      {
        "country_name": "Liberia",
        "country_grouping": "Africa",
        "country_code": "LBR",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "LBY",
        "country_name": "Libya",
        "country_grouping": "Africa"
      },
      {
        "country_name": "Saint Lucia",
        "country_grouping": "Americas",
        "country_code": "LCA",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "LIE",
        "country_name": "Liechtenstein",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Visa",
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Residence Permit"
        ]
      },
      {
        "country_code": "LKA",
        "country_name": "Sri Lanka",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_name": "Lesotho",
        "country_code": "LSO"
      },
      {
        "country_code": "LTU",
        "country_grouping": "Europe",
        "country_name": "Lithuania",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Residence Permit",
          "Passport",
          "Visa"
        ]
      },
      {
        "country_grouping": "Europe",
        "country_name": "Luxembourg",
        "country_code": "LUX",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ],
        "country_code": "LVA",
        "country_name": "Latvia",
        "country_grouping": "Europe"
      },
      {
        "country_code": "MAC",
        "country_name": "Macao",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence"
        ],
        "country_code": "MAF",
        "country_name": "Saint Martin (French part)",
        "country_grouping": "Americas"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_name": "Morocco",
        "country_grouping": "Africa",
        "country_code": "MAR"
      },
      {
        "country_grouping": "Europe",
        "country_name": "Monaco",
        "country_code": "MCO",
        "doc_types_list": [
          "Passport",
          "National Identity Card",
          "Residence Permit"
        ]
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
        "country_code": "MDG",
        "country_name": "Madagascar",
        "country_grouping": "Africa"
      },
      {
        "country_grouping": "Asia",
        "country_name": "Maldives",
        "country_code": "MDV",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Voter Id (INE)",
          "Voter Id (IFE)",
          "Driving Licence",
          "Work Permit",
          "Passport"
        ],
        "country_code": "MEX",
        "country_name": "Mexico",
        "country_grouping": "Americas"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "MHL",
        "country_grouping": "Oceania",
        "country_name": "Marshall Islands"
      },
      {
        "country_grouping": "Europe",
        "country_name": "Macedonia, The former Yugoslav Republic of",
        "country_code": "MKD",
        "doc_types_list": [
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
        "country_name": "Mali",
        "country_grouping": "Africa",
        "country_code": "MLI"
      },
      {
        "country_name": "Malta",
        "country_grouping": "Europe",
        "country_code": "MLT",
        "doc_types_list": [
          "Visa",
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "country_name": "Myanmar",
        "country_grouping": "Asia",
        "country_code": "MMR",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "MNE",
        "country_grouping": "Europe",
        "country_name": "Montenegro",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_grouping": "Asia",
        "country_name": "Mongolia",
        "country_code": "MNG",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_code": "MNP",
        "country_name": "Northern Mariana Islands",
        "country_grouping": "Oceania",
        "doc_types_list": [
          "Driving Licence"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_name": "Mozambique",
        "country_grouping": "Africa",
        "country_code": "MOZ"
      },
      {
        "country_name": "Montserrat",
        "country_grouping": "Americas",
        "country_code": "MSR",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ],
        "country_code": "MUS",
        "country_grouping": "Africa",
        "country_name": "Mauritius"
      },
      {
        "country_name": "Malawi",
        "country_grouping": "Africa",
        "country_code": "MWI",
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_grouping": "Asia",
        "country_name": "Malaysia",
        "country_code": "MYS",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card (MyKAD)",
          "National Identity Card (MyTentera)",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "country_code": "NAM",
        "country_grouping": "Africa",
        "country_name": "Namibia",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_name": "Niger",
        "country_code": "NER"
      },
      {
        "country_code": "NGA",
        "country_grouping": "Africa",
        "country_name": "Nigeria",
        "doc_types_list": [
          "Driving Licence",
          "Voter Id",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "NIC",
        "country_grouping": "Americas",
        "country_name": "Nicaragua"
      },
      {
        "country_name": "Netherlands",
        "country_grouping": "Europe",
        "country_code": "NLD",
        "doc_types_list": [
          "Residence Permit",
          "Visa",
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_code": "NOR",
        "country_name": "Norway",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_name": "Nepal",
        "country_code": "NPL"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "NRU",
        "country_name": "Nauru",
        "country_grouping": "Oceania"
      },
      {
        "country_grouping": "Oceania",
        "country_name": "New Zealand",
        "country_code": "NZL",
        "doc_types_list": [
          "Passport",
          "Driving Licence"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Residence Permit",
          "Passport"
        ],
        "country_code": "OMN",
        "country_grouping": "Asia",
        "country_name": "Oman"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Pakistan",
        "country_grouping": "Asia",
        "country_code": "PAK"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Panama",
        "country_grouping": "Americas",
        "country_code": "PAN"
      },
      {
        "country_grouping": "Oceania",
        "country_name": "Pitcairn",
        "country_code": "PCN",
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
        "country_code": "PER",
        "country_grouping": "Americas",
        "country_name": "Peru"
      },
      {
        "country_grouping": "Asia",
        "country_name": "Philippines",
        "country_code": "PHL",
        "doc_types_list": [
          "Driving Licence",
          "Postal Identity Card",
          "Professional Qualification Card",
          "Social Security Card",
          "National Identity Card",
          "Voter Id",
          "Passport"
        ]
      },
      {
        "country_grouping": "Oceania",
        "country_name": "Palau",
        "country_code": "PLW",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Papua New Guinea",
        "country_grouping": "Oceania",
        "country_code": "PNG"
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Residence Permit",
          "Driving Licence",
          "Passport Card",
          "Passport",
          "Visa"
        ],
        "country_grouping": "Europe",
        "country_name": "Poland",
        "country_code": "POL"
      },
      {
        "country_grouping": "Americas",
        "country_name": "Puerto Rico",
        "country_code": "PRI",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card"
        ]
      },
      {
        "country_code": "PRK",
        "country_name": "Korea, The Democratic People's Republic of",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport",
          "Visa",
          "Driving Licence",
          "National Identity Card",
          "Residence Permit"
        ],
        "country_code": "PRT",
        "country_name": "Portugal",
        "country_grouping": "Europe"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_grouping": "Americas",
        "country_name": "Paraguay",
        "country_code": "PRY"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_name": "Palestine, State of",
        "country_code": "PSE"
      },
      {
        "doc_types_list": [
          "Driving Licence"
        ],
        "country_code": "PYF",
        "country_grouping": "Oceania",
        "country_name": "French Polynesia"
      },
      {
        "country_code": "QAT",
        "country_grouping": "Asia",
        "country_name": "Qatar",
        "doc_types_list": [
          "National Identity Card",
          "Residence Permit",
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_code": "ROU",
        "country_name": "Romania",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Residence Permit",
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_code": "RUS",
        "country_name": "Russian Federation",
        "country_grouping": "Europe",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card (Internal Passport)"
        ]
      },
      {
        "country_name": "Rwanda",
        "country_grouping": "Africa",
        "country_code": "RWA",
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Residence Permit",
          "Passport"
        ],
        "country_grouping": "Asia",
        "country_name": "Saudi Arabia",
        "country_code": "SAU"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "SDN",
        "country_name": "Sudan",
        "country_grouping": "Africa"
      },
      {
        "country_code": "SEN",
        "country_name": "Senegal",
        "country_grouping": "Africa",
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_code": "SGP",
        "country_name": "Singapore",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Work Permit (FIN card)",
          "National Identity Card (NRIC)",
          "Work Permit",
          "Work Permit (S Pass)",
          "Work Permit (Employment Pass)",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Oceania",
        "country_name": "Solomon Islands",
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
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ],
        "country_name": "El Salvador",
        "country_grouping": "Americas",
        "country_code": "SLV"
      },
      {
        "country_name": "San Marino",
        "country_grouping": "Europe",
        "country_code": "SMR",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_code": "SOM",
        "country_name": "Somalia",
        "country_grouping": "Africa",
        "doc_types_list": [
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card"
        ],
        "country_code": "SRB",
        "country_grouping": "Europe",
        "country_name": "Serbia"
      },
      {
        "country_name": "South Sudan",
        "country_grouping": "Africa",
        "country_code": "SSD",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_code": "STP",
        "country_grouping": "Africa",
        "country_name": "Sao Tome and Principe",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Americas",
        "country_name": "Suriname",
        "country_code": "SUR"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Visa",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_grouping": "Europe",
        "country_name": "Slovakia",
        "country_code": "SVK"
      },
      {
        "country_grouping": "Europe",
        "country_name": "Slovenia",
        "country_code": "SVN",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "country_name": "Sweden",
        "country_grouping": "Europe",
        "country_code": "SWE",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card",
          "Tax Id",
          "Visa",
          "Residence Permit"
        ]
      },
      {
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ],
        "country_code": "SWZ",
        "country_grouping": "Africa",
        "country_name": "Swaziland"
      },
      {
        "country_code": "SYC",
        "country_name": "Seychelles",
        "country_grouping": "Africa",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Syrian Arab Republic",
        "country_grouping": "Asia",
        "country_code": "SYR",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Turks and Caicos Islands",
        "country_grouping": "Americas",
        "country_code": "TCA",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_name": "Chad",
        "country_grouping": "Africa",
        "country_code": "TCD",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Africa",
        "country_name": "Togo",
        "country_code": "TGO"
      },
      {
        "country_name": "Thailand",
        "country_grouping": "Asia",
        "country_code": "THA",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "National Identity Card"
        ]
      },
      {
        "country_code": "TJK",
        "country_name": "Tajikistan",
        "country_grouping": "Asia",
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ]
      },
      {
        "country_grouping": "Asia",
        "country_name": "Turkmenistan",
        "country_code": "TKM",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "TON",
        "country_grouping": "Oceania",
        "country_name": "Tonga"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_code": "TTO",
        "country_grouping": "Americas",
        "country_name": "Trinidad and Tobago"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_code": "TUN",
        "country_grouping": "Africa",
        "country_name": "Tunisia"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Residence Permit",
          "Passport"
        ],
        "country_code": "TUR",
        "country_grouping": "Asia",
        "country_name": "Turkey"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_code": "TUV",
        "country_name": "Tuvalu",
        "country_grouping": "Oceania"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ],
        "country_code": "TWN",
        "country_name": "Taiwan (Province of China)",
        "country_grouping": "Asia"
      },
      {
        "country_grouping": "Africa",
        "country_name": "Tanzania, United Republic of",
        "country_code": "TZA",
        "doc_types_list": [
          "Driving Licence",
          "Voter Id",
          "National Identity Card",
          "Passport",
          "Residence Permit"
        ]
      },
      {
        "country_code": "UGA",
        "country_name": "Uganda",
        "country_grouping": "Africa",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "country_name": "Ukraine",
        "country_grouping": "Europe",
        "country_code": "UKR",
        "doc_types_list": [
          "Passport",
          "Driving Licence",
          "National Identity Card"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card",
          "Driving Licence",
          "Passport"
        ],
        "country_code": "URY",
        "country_name": "Uruguay",
        "country_grouping": "Americas"
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
        "country_grouping": "Americas",
        "country_name": "United States of America",
        "country_code": "USA"
      },
      {
        "country_name": "Uzbekistan",
        "country_grouping": "Asia",
        "country_code": "UZB",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "country_grouping": "Europe",
        "country_name": "Holy See",
        "country_code": "VAT",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Saint Vincent and the Grenadines",
        "country_grouping": "Americas",
        "country_code": "VCT"
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ],
        "country_grouping": "Americas",
        "country_name": "Venezuela (Bolivarian Republic of)",
        "country_code": "VEN"
      },
      {
        "country_name": "Virgin Islands (British)",
        "country_grouping": "Americas",
        "country_code": "VGB",
        "doc_types_list": [
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "National Identity Card"
        ],
        "country_code": "VIR",
        "country_name": "Virgin Islands (U.S.)",
        "country_grouping": "Americas"
      },
      {
        "country_grouping": "Asia",
        "country_name": "Viet Nam",
        "country_code": "VNM",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_name": "Vanuatu",
        "country_grouping": "Oceania",
        "country_code": "VUT"
      },
      {
        "doc_types_list": [
          "Passport"
        ],
        "country_grouping": "Oceania",
        "country_name": "Samoa",
        "country_code": "WSM"
      },
      {
        "country_name": "Yemen",
        "country_grouping": "Asia",
        "country_code": "YEM",
        "doc_types_list": [
          "Driving Licence",
          "Passport",
          "Passport (Overseas )"
        ]
      },
      {
        "country_code": "ZAF",
        "country_name": "South Africa",
        "country_grouping": "Africa",
        "doc_types_list": [
          "Driving Licence",
          "National Identity Card",
          "Passport"
        ]
      },
      {
        "doc_types_list": [
          "Driving Licence",
          "Passport"
        ],
        "country_name": "Zambia",
        "country_grouping": "Africa",
        "country_code": "ZMB"
      },
      {
        "country_name": "Zimbabwe",
        "country_grouping": "Africa",
        "country_code": "ZWE",
        "doc_types_list": [
          "Passport",
          "National Identity Card"
        ]
      }
    ]
string_ending_delimiter
}

kill('TERM', $pid);
