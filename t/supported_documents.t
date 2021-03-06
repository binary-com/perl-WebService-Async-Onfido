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
        "country_code": "AFG",
        "country_grouping": "Asia",
        "country_name": "Afghanistan",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "AGO",
        "country_grouping": "Africa",
        "country_name": "Angola",
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
        "country_code": "ALB",
        "country_grouping": "Europe",
        "country_name": "Albania",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "AND",
        "country_grouping": "Europe",
        "country_name": "Andorra",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
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
        "country_code": "ARG",
        "country_grouping": "Americas",
        "country_name": "Argentina",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "ARM",
        "country_grouping": "Asia",
        "country_name": "Armenia",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "ASM",
        "country_grouping": "Oceania",
        "country_name": "American Samoa",
        "doc_types_list": [
            "Driving Licence"
        ]
      },
      {
        "country_code": "ATG",
        "country_grouping": "Americas",
        "country_name": "Antigua and Barbuda",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "AUS",
        "country_grouping": "Oceania",
        "country_name": "Australia",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "AUT",
        "country_grouping": "Europe",
        "country_name": "Austria",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "AZE",
        "country_grouping": "Asia",
        "country_name": "Azerbaijan",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "BDI",
        "country_grouping": "Africa",
        "country_name": "Burundi",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "BEL",
        "country_grouping": "Europe",
        "country_name": "Belgium",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit (German)",
            "Residence Permit",
            "Visa"
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
        "country_code": "BGR",
        "country_grouping": "Europe",
        "country_name": "Bulgaria",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "BHR",
        "country_grouping": "Asia",
        "country_name": "Bahrain",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "BHS",
        "country_grouping": "Americas",
        "country_name": "Bahamas",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "BIH",
        "country_grouping": "Europe",
        "country_name": "Bosnia and Herzegovina",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "BLM",
        "country_grouping": "Americas",
        "country_name": "Saint Barthelemy",
        "doc_types_list": [
            "Driving Licence"
        ]
      },
      {
        "country_code": "BLR",
        "country_grouping": "Europe",
        "country_name": "Belarus",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "BLZ",
        "country_grouping": "Americas",
        "country_name": "Belize",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "BMU",
        "country_grouping": "Americas",
        "country_name": "Bermuda",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "BOL",
        "country_grouping": "Americas",
        "country_name": "Bolivia (Plurinational State of)",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "BRA",
        "country_grouping": "Americas",
        "country_name": "Brazil",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card (RG Card)",
            "Passport"
        ]
      },
      {
        "country_code": "BRB",
        "country_grouping": "Americas",
        "country_name": "Barbados",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "BRN",
        "country_grouping": "Asia",
        "country_name": "Brunei Darussalam",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "BTN",
        "country_grouping": "Asia",
        "country_name": "Bhutan",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "BWA",
        "country_grouping": "Africa",
        "country_name": "Botswana",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "CAF",
        "country_grouping": "Africa",
        "country_name": "Central African Republic",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "CAN",
        "country_grouping": "Americas",
        "country_name": "Canada",
        "doc_types_list": [
            "Driving Licence",
            "National Health Insurance Card (Health Card)",
            "National Health Insurance Card",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "CHE",
        "country_grouping": "Europe",
        "country_name": "Switzerland",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "CHL",
        "country_grouping": "Americas",
        "country_name": "Chile",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "CHN",
        "country_grouping": "Asia",
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
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "CMR",
        "country_grouping": "Africa",
        "country_name": "Cameroon",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "COD",
        "country_grouping": "Africa",
        "country_name": "Congo (The Democratic Republic of the)",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "COG",
        "country_grouping": "Africa",
        "country_name": "Congo",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "COL",
        "country_grouping": "Americas",
        "country_name": "Colombia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "COM",
        "country_grouping": "Africa",
        "country_name": "Comoros",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "CPV",
        "country_grouping": "Africa",
        "country_name": "Cabo Verde",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "CRI",
        "country_grouping": "Americas",
        "country_name": "Costa Rica",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "CUB",
        "country_grouping": "Americas",
        "country_name": "Cuba",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "CYM",
        "country_grouping": "Americas",
        "country_name": "Cayman Islands",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "CYP",
        "country_grouping": "Asia",
        "country_name": "Cyprus",
        "doc_types_list": [
            "Driving Licence (paper)",
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "CZE",
        "country_grouping": "Europe",
        "country_name": "Czechia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "DEU",
        "country_grouping": "Europe",
        "country_name": "Germany",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "DJI",
        "country_grouping": "Africa",
        "country_name": "Djibouti",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "DMA",
        "country_grouping": "Americas",
        "country_name": "Dominica",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "DNK",
        "country_grouping": "Europe",
        "country_name": "Denmark",
        "doc_types_list": [
            "Driving Licence",
            "Passport (faroe islands)",
            "Passport Card",
            "Passport",
            "Residence Permit",
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
        "country_code": "DZA",
        "country_grouping": "Africa",
        "country_name": "Algeria",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "ECU",
        "country_grouping": "Americas",
        "country_name": "Ecuador",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
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
        "country_code": "ERI",
        "country_grouping": "Africa",
        "country_name": "Eritrea",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "ESP",
        "country_grouping": "Europe",
        "country_name": "Spain",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "EST",
        "country_grouping": "Europe",
        "country_name": "Estonia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "ETH",
        "country_grouping": "Africa",
        "country_name": "Ethiopia",
        "doc_types_list": [
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "FIN",
        "country_grouping": "Europe",
        "country_name": "Finland",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "FJI",
        "country_grouping": "Oceania",
        "country_name": "Fiji",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "FRA",
        "country_grouping": "Europe",
        "country_name": "France",
        "doc_types_list": [
            "Driving Licence",
            "National Health Insurance Card (Carte Vitale)",
            "National Identity Card",
            "Passport",
            "Residence Permit",
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
        "country_code": "FSM",
        "country_grouping": "Oceania",
        "country_name": "Micronesia (Federated States of)",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "GAB",
        "country_grouping": "Africa",
        "country_name": "Gabon",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "GBR",
        "country_grouping": "Europe",
        "country_name": "United Kingdom of Great Britain and Northern Ireland",
        "doc_types_list": [
            "Asylum Registration Card",
            "Certificate of Naturalisation",
            "Driving Licence",
            "Home Office Letter",
            "Immigration Status Document",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "GEO",
        "country_grouping": "Asia",
        "country_name": "Georgia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "GGY",
        "country_grouping": "Europe",
        "country_name": "Guernsey",
        "doc_types_list": [
            "Driving Licence"
        ]
      },
      {
        "country_code": "GHA",
        "country_grouping": "Africa",
        "country_name": "Ghana",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "GIB",
        "country_grouping": "Europe",
        "country_name": "Gibraltar",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "GIN",
        "country_grouping": "Africa",
        "country_name": "Guinea",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "GMB",
        "country_grouping": "Africa",
        "country_name": "Gambia",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "GNB",
        "country_grouping": "Africa",
        "country_name": "Guinea-Bissau",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "GNQ",
        "country_grouping": "Africa",
        "country_name": "Equatorial Guinea",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "GRC",
        "country_grouping": "Europe",
        "country_name": "Greece",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "GRD",
        "country_grouping": "Americas",
        "country_name": "Grenada",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "GRL",
        "country_grouping": "Americas",
        "country_name": "Greenland",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "GTM",
        "country_grouping": "Americas",
        "country_name": "Guatemala",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "GUM",
        "country_grouping": "Oceania",
        "country_name": "Guam",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card"
        ]
      },
      {
        "country_code": "GUY",
        "country_grouping": "Americas",
        "country_name": "Guyana",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "HKG",
        "country_grouping": "Asia",
        "country_name": "Hong Kong",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card (HKID)",
            "Passport"
        ]
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
        "country_code": "HRV",
        "country_grouping": "Europe",
        "country_name": "Croatia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "HTI",
        "country_grouping": "Americas",
        "country_name": "Haiti",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "HUN",
        "country_grouping": "Europe",
        "country_name": "Hungary",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "IDN",
        "country_grouping": "Asia",
        "country_name": "Indonesia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "IMN",
        "country_grouping": "Europe",
        "country_name": "Isle of Man",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "IND",
        "country_grouping": "Asia",
        "country_name": "India",
        "doc_types_list": [
            "National Identity Card (Aadhaar Card)",
            "Passport",
            "Tax Id (PAN Card)",
            "Voter Id"
        ]
      },
      {
        "country_code": "IRL",
        "country_grouping": "Europe",
        "country_name": "Ireland",
        "doc_types_list": [
            "Driving Licence",
            "Passport Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "IRN",
        "country_grouping": "Asia",
        "country_name": "Iran (Islamic Republic of)",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "IRQ",
        "country_grouping": "Asia",
        "country_name": "Iraq",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "ISL",
        "country_grouping": "Europe",
        "country_name": "Iceland",
        "doc_types_list": [
            "Driving Licence",
            "Passport",
            "Visa"
        ]
      },
      {
        "country_code": "ISR",
        "country_grouping": "Asia",
        "country_name": "Israel",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "ITA",
        "country_grouping": "Europe",
        "country_name": "Italy",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
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
        "country_code": "JEY",
        "country_grouping": "Europe",
        "country_name": "Jersey",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "JOR",
        "country_grouping": "Asia",
        "country_name": "Jordan",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "JPN",
        "country_grouping": "Asia",
        "country_name": "Japan",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card (Individual Number Card)",
            "Passport",
            "Postal Identity Card (Juminhyo)",
            "Residence Permit",
            "Social Security Card (Individual Number Paper Slip)"
        ]
      },
      {
        "country_code": "KAZ",
        "country_grouping": "Asia",
        "country_name": "Kazakhstan",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "KEN",
        "country_grouping": "Africa",
        "country_name": "Kenya",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "KGZ",
        "country_grouping": "Asia",
        "country_name": "Kyrgyzstan",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "KHM",
        "country_grouping": "Asia",
        "country_name": "Cambodia",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "KIR",
        "country_grouping": "Oceania",
        "country_name": "Kiribati",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "KNA",
        "country_grouping": "Americas",
        "country_name": "Saint Kitts and Nevis",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "KOR",
        "country_grouping": "Asia",
        "country_name": "Korea, The Republic of",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "KWT",
        "country_grouping": "Asia",
        "country_name": "Kuwait",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "LAO",
        "country_grouping": "Asia",
        "country_name": "Lao People's Democratic Republic",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "LBN",
        "country_grouping": "Asia",
        "country_name": "Lebanon",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "LBR",
        "country_grouping": "Africa",
        "country_name": "Liberia",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "LBY",
        "country_grouping": "Africa",
        "country_name": "Libya",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "LCA",
        "country_grouping": "Americas",
        "country_name": "Saint Lucia",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "LIE",
        "country_grouping": "Europe",
        "country_name": "Liechtenstein",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "LKA",
        "country_grouping": "Asia",
        "country_name": "Sri Lanka",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "LSO",
        "country_grouping": "Africa",
        "country_name": "Lesotho",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "LTU",
        "country_grouping": "Europe",
        "country_name": "Lithuania",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "LUX",
        "country_grouping": "Europe",
        "country_name": "Luxembourg",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "LVA",
        "country_grouping": "Europe",
        "country_name": "Latvia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
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
        "country_code": "MAF",
        "country_grouping": "Americas",
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
        "country_code": "MCO",
        "country_grouping": "Europe",
        "country_name": "Monaco",
        "doc_types_list": [
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "MDA",
        "country_grouping": "Europe",
        "country_name": "Moldova, The Republic of",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "MDG",
        "country_grouping": "Africa",
        "country_name": "Madagascar",
        "doc_types_list": [
            "Passport"
        ]
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
        "country_code": "MEX",
        "country_grouping": "Americas",
        "country_name": "Mexico",
        "doc_types_list": [
            "Driving Licence",
            "Passport",
            "Voter Id (IFE)",
            "Voter Id (INE)",
            "Work Permit"
        ]
      },
      {
        "country_code": "MHL",
        "country_grouping": "Oceania",
        "country_name": "Marshall Islands",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "MKD",
        "country_grouping": "Europe",
        "country_name": "Macedonia, The former Yugoslav Republic of",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "MLI",
        "country_grouping": "Africa",
        "country_name": "Mali",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "MLT",
        "country_grouping": "Europe",
        "country_name": "Malta",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "MMR",
        "country_grouping": "Asia",
        "country_name": "Myanmar",
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
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "MNG",
        "country_grouping": "Asia",
        "country_name": "Mongolia",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "MNP",
        "country_grouping": "Oceania",
        "country_name": "Northern Mariana Islands",
        "doc_types_list": [
            "Driving Licence"
        ]
      },
      {
        "country_code": "MOZ",
        "country_grouping": "Africa",
        "country_name": "Mozambique",
        "doc_types_list": [
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "MSR",
        "country_grouping": "Americas",
        "country_name": "Montserrat",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "MUS",
        "country_grouping": "Africa",
        "country_name": "Mauritius",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "MWI",
        "country_grouping": "Africa",
        "country_name": "Malawi",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "MYS",
        "country_grouping": "Asia",
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
        "country_code": "NER",
        "country_grouping": "Africa",
        "country_name": "Niger",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "NGA",
        "country_grouping": "Africa",
        "country_name": "Nigeria",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Voter Id"
        ]
      },
      {
        "country_code": "NIC",
        "country_grouping": "Americas",
        "country_name": "Nicaragua",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "NLD",
        "country_grouping": "Europe",
        "country_name": "Netherlands",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "NOR",
        "country_grouping": "Europe",
        "country_name": "Norway",
        "doc_types_list": [
            "Driving Licence",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "NPL",
        "country_grouping": "Asia",
        "country_name": "Nepal",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "NRU",
        "country_grouping": "Oceania",
        "country_name": "Nauru",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "NZL",
        "country_grouping": "Oceania",
        "country_name": "New Zealand",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "OMN",
        "country_grouping": "Asia",
        "country_name": "Oman",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "PAK",
        "country_grouping": "Asia",
        "country_name": "Pakistan",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "PAN",
        "country_grouping": "Americas",
        "country_name": "Panama",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "PCN",
        "country_grouping": "Oceania",
        "country_name": "Pitcairn",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "PER",
        "country_grouping": "Americas",
        "country_name": "Peru",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "PHL",
        "country_grouping": "Asia",
        "country_name": "Philippines",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Postal Identity Card",
            "Professional Qualification Card",
            "Social Security Card",
            "Voter Id"
        ]
      },
      {
        "country_code": "PLW",
        "country_grouping": "Oceania",
        "country_name": "Palau",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "PNG",
        "country_grouping": "Oceania",
        "country_name": "Papua New Guinea",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "POL",
        "country_grouping": "Europe",
        "country_name": "Poland",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "PRI",
        "country_grouping": "Americas",
        "country_name": "Puerto Rico",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card"
        ]
      },
      {
        "country_code": "PRK",
        "country_grouping": "Asia",
        "country_name": "Korea, The Democratic People's Republic of",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "PRT",
        "country_grouping": "Europe",
        "country_name": "Portugal",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "PRY",
        "country_grouping": "Americas",
        "country_name": "Paraguay",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "PSE",
        "country_grouping": "Asia",
        "country_name": "Palestine, State of",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "PYF",
        "country_grouping": "Oceania",
        "country_name": "French Polynesia",
        "doc_types_list": [
            "Driving Licence"
        ]
      },
      {
        "country_code": "QAT",
        "country_grouping": "Asia",
        "country_name": "Qatar",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "ROU",
        "country_grouping": "Europe",
        "country_name": "Romania",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "RUS",
        "country_grouping": "Europe",
        "country_name": "Russian Federation",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card (Internal Passport)",
            "Passport"
        ]
      },
      {
        "country_code": "RWA",
        "country_grouping": "Africa",
        "country_name": "Rwanda",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "SAU",
        "country_grouping": "Asia",
        "country_name": "Saudi Arabia",
        "doc_types_list": [
            "Driving Licence",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "SDN",
        "country_grouping": "Africa",
        "country_name": "Sudan",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "SEN",
        "country_grouping": "Africa",
        "country_name": "Senegal",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "SGP",
        "country_grouping": "Asia",
        "country_name": "Singapore",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card (NRIC)",
            "National Identity Card",
            "Passport",
            "Work Permit (Employment Pass)",
            "Work Permit (FIN card)",
            "Work Permit (S Pass)",
            "Work Permit"
        ]
      },
      {
        "country_code": "SLB",
        "country_grouping": "Oceania",
        "country_name": "Solomon Islands",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "SLE",
        "country_grouping": "Africa",
        "country_name": "Sierra Leone",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "SLV",
        "country_grouping": "Americas",
        "country_name": "El Salvador",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "SMR",
        "country_grouping": "Europe",
        "country_name": "San Marino",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "SOM",
        "country_grouping": "Africa",
        "country_name": "Somalia",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "SRB",
        "country_grouping": "Europe",
        "country_name": "Serbia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "SSD",
        "country_grouping": "Africa",
        "country_name": "South Sudan",
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
        "country_code": "SUR",
        "country_grouping": "Americas",
        "country_name": "Suriname",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "SVK",
        "country_grouping": "Europe",
        "country_name": "Slovakia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "SVN",
        "country_grouping": "Europe",
        "country_name": "Slovenia",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Visa"
        ]
      },
      {
        "country_code": "SWE",
        "country_grouping": "Europe",
        "country_name": "Sweden",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Tax Id",
            "Visa"
        ]
      },
      {
        "country_code": "SWZ",
        "country_grouping": "Africa",
        "country_name": "Swaziland",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "SYC",
        "country_grouping": "Africa",
        "country_name": "Seychelles",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "SYR",
        "country_grouping": "Asia",
        "country_name": "Syrian Arab Republic",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "TCA",
        "country_grouping": "Americas",
        "country_name": "Turks and Caicos Islands",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "TCD",
        "country_grouping": "Africa",
        "country_name": "Chad",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "TGO",
        "country_grouping": "Africa",
        "country_name": "Togo",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "THA",
        "country_grouping": "Asia",
        "country_name": "Thailand",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "TJK",
        "country_grouping": "Asia",
        "country_name": "Tajikistan",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "TKM",
        "country_grouping": "Asia",
        "country_name": "Turkmenistan",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "TON",
        "country_grouping": "Oceania",
        "country_name": "Tonga",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "TTO",
        "country_grouping": "Americas",
        "country_name": "Trinidad and Tobago",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "TUN",
        "country_grouping": "Africa",
        "country_name": "Tunisia",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "TUR",
        "country_grouping": "Asia",
        "country_name": "Turkey",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "TUV",
        "country_grouping": "Oceania",
        "country_name": "Tuvalu",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "TWN",
        "country_grouping": "Asia",
        "country_name": "Taiwan (Province of China)",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit"
        ]
      },
      {
        "country_code": "TZA",
        "country_grouping": "Africa",
        "country_name": "Tanzania, United Republic of",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport",
            "Residence Permit",
            "Voter Id"
        ]
      },
      {
        "country_code": "UGA",
        "country_grouping": "Africa",
        "country_name": "Uganda",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "UKR",
        "country_grouping": "Europe",
        "country_name": "Ukraine",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "URY",
        "country_grouping": "Americas",
        "country_name": "Uruguay",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "USA",
        "country_grouping": "Americas",
        "country_name": "United States of America",
        "doc_types_list": [
            "Driving Licence (Enhanced)",
            "Driving Licence (Intermediate)",
            "Driving Licence (Vertical )",
            "Driving Licence",
            "National Identity Card (Real ID ) (State ID)",
            "National Identity Card (State ID)",
            "National Identity Card (State Identity Card) (State ID)",
            "Passport Card",
            "Passport",
            "Residence Permit (Green Card)",
            "Visa",
            "Work Permit"
        ]
      },
      {
        "country_code": "UZB",
        "country_grouping": "Asia",
        "country_name": "Uzbekistan",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "VAT",
        "country_grouping": "Europe",
        "country_name": "Holy See",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "VCT",
        "country_grouping": "Americas",
        "country_name": "Saint Vincent and the Grenadines",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "VEN",
        "country_grouping": "Americas",
        "country_name": "Venezuela (Bolivarian Republic of)",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "VGB",
        "country_grouping": "Americas",
        "country_name": "Virgin Islands (British)",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "VIR",
        "country_grouping": "Americas",
        "country_name": "Virgin Islands (U.S.)",
        "doc_types_list": [
            "National Identity Card"
        ]
      },
      {
        "country_code": "VNM",
        "country_grouping": "Asia",
        "country_name": "Viet Nam",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "VUT",
        "country_grouping": "Oceania",
        "country_name": "Vanuatu",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "WSM",
        "country_grouping": "Oceania",
        "country_name": "Samoa",
        "doc_types_list": [
            "Passport"
        ]
      },
      {
        "country_code": "YEM",
        "country_grouping": "Asia",
        "country_name": "Yemen",
        "doc_types_list": [
            "Driving Licence",
            "Passport (Overseas )",
            "Passport"
        ]
      },
      {
        "country_code": "ZAF",
        "country_grouping": "Africa",
        "country_name": "South Africa",
        "doc_types_list": [
            "Driving Licence",
            "National Identity Card",
            "Passport"
        ]
      },
      {
        "country_code": "ZMB",
        "country_grouping": "Africa",
        "country_name": "Zambia",
        "doc_types_list": [
            "Driving Licence",
            "Passport"
        ]
      },
      {
        "country_code": "ZWE",
        "country_grouping": "Africa",
        "country_name": "Zimbabwe",
        "doc_types_list": [
            "National Identity Card",
            "Passport"
        ]
      }
    ]
string_ending_delimiter
}

kill('TERM', $pid);
