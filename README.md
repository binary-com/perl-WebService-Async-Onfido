# NAME

WebService::Async::Onfido - unofficial support for the Onfido identity verification service

# SYNOPSIS

# DESCRIPTION

## hook

Executes a hook, if specified at configure time.

Takes the following:

- `$hook` - the hook to execute
- `$data` - data to pass to the sub

It returns `undef`

## applicant\_list

Retrieves a list of all known applicants.

Returns a [Ryu::Source](https://metacpan.org/pod/Ryu%3A%3ASource) which will emit one [WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant) for
each applicant found.

## paging

Supports paging through HTTP GET requests.

- `$starting_uri` - the initial [URI](https://metacpan.org/pod/URI) to request
- `$factory` - a `sub` that we will call with a [Ryu::Source](https://metacpan.org/pod/Ryu%3A%3ASource) and expect to return
a second response-processing `sub`.

Returns a [Ryu::Source](https://metacpan.org/pod/Ryu%3A%3ASource).

## extract\_links

Given a set of strings representing the `Link` headers in an HTTP response,
extracts the URIs based on the `rel` attribute as described in
[RFC5988](http://tools.ietf.org/html/rfc5988).

Returns a list of key, value pairs where the key contains the lowercase `rel` value
and the value is a [URI](https://metacpan.org/pod/URI) instance.

    my %links = $self->extract_links($res->header('Link'))
    print "Last page would be $links{last}"

## applicant\_create

Creates a new applicant record.

See accessors in [WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant) for a full list of supported attributes.
These can be passed as named parameters to this method.

Returns a [Future](https://metacpan.org/pod/Future) which resolves to a [WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant)
instance on successful completion.

## applicant\_update

Updates a single applicant.

Returns a [Future](https://metacpan.org/pod/Future) which resolves to empty on success.

## applicant\_delete

Deletes a single applicant.

Returns a [Future](https://metacpan.org/pod/Future) which resolves to empty on success.

## applicant\_get

Retrieve a single applicant.

Returns a [Future](https://metacpan.org/pod/Future) which resolves to a [WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant)

## document\_list

List all documents for a given [WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant).

Takes the following named parameters:

- `applicant_id` - the ["id" in WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant#id) for the applicant to query

Returns a [Ryu::Source](https://metacpan.org/pod/Ryu%3A%3ASource) which will emit one [WebService::Async::Onfido::Document](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3ADocument) for
each document found.

## get\_document\_details

Gets a document object for a given [WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant).

Takes the following named parameters:

- `applicant_id` - the ["id" in WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant#id) for the applicant to query
- `document_id` - the ["id" in WebService::Async::Onfido::Document](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3ADocument#id) for the document to query

Returns a Future object which consists of a [WebService::Async::Onfido::Document](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3ADocument)

## photo\_list

List all photos for a given [WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant).

Takes the following named parameters:

- `applicant_id` - the ["id" in WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant#id) for the applicant to query

Returns a [Ryu::Source](https://metacpan.org/pod/Ryu%3A%3ASource) which will emit one [WebService::Async::Onfido::Photo](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3APhoto) for
each photo found.

## get\_photo\_details

Gets a live\_photo object for a given [WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant).

Takes the following named parameters:

- `live_photo_id` - the ["id" in WebService::Async::Onfido::Photo](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3APhoto#id) for the document to query

Returns a Future object which consists of a [WebService::Async::Onfido::Photo](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3APhoto)

## document\_upload

Uploads a single document for a given applicant.

Takes the following named parameters:

- `type` - can be `passport`, `photo`, `poa`
- `side` - which side, either `front` or `back`
- `issuing_country` - which country this document is for
- `filename` - the file name to use for this item
- `data` - the bytes for this image file (must be in JPEG format)

## live\_photo\_upload

Uploads a single "live photo" for a given applicant.

Takes the following named parameters:

- `applicant_id` - ID for the person this photo relates to
- `advanced_validation` - perform additional validation (ensure we only have a single face)
- `filename` - the file name to use for this item
- `data` - the bytes for this image file (must be in JPEG format)

## applicant\_check

Perform an identity check on an applicant.

This is the main method for dealing with verification - once you have created
the applicant and uploaded some documents, call this to start the process of
checking the documents and details, and generating the reports.

[https://documentation.onfido.com/#check-object](https://documentation.onfido.com/#check-object)

Takes the following named parameters:

- `applicant_id` - the applicant requesting the check
- `document_ids` - arrayref of documents ids to be analyzed on this check
- `report_names` - arrayref of the reports to be made (e.g: document, facial\_similarity\_photo)
- `tags` - custom tags to apply to these reports
- `suppress_form_emails` - if true, do **not** send out the email to
the applicant
- `asynchronous` - return immediately and perform check in the background (default true since v3)
- `charge_applicant_for_check` - the applicant must enter payment
details for this check, and it will not count towards the quota for this
service account
- `consider` - used for sandbox API testing only

Returns a [Future](https://metacpan.org/pod/Future) which will resolve with the result.

## download\_photo

Gets a live\_photo in a form of binary data for a given [WebService::Async::Onfido::Photo](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3APhoto).

Takes the following named parameters:

- `live_photo_id` - the ["id" in WebService::Async::Onfido::Photo](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3APhoto#id) for the document to query

Returns a photo file blob

## download\_document

Gets a document in a form of binary data for a given [WebService::Async::Onfido::Document](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3ADocument).

Takes the following named parameters:

- `applicant_id` - the ["id" in WebService::Async::Onfido::Applicant](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3AApplicant#id) for the applicant to query
- `document_id` - the ["id" in WebService::Async::Onfido::Document](https://metacpan.org/pod/WebService%3A%3AAsync%3A%3AOnfido%3A%3ADocument#id) for the document to query

Returns a document file blob

## countries\_list

Returns a hashref containing 3-letter country codes as keys and supporting status
as their value.

## supported\_documents\_list

Returns an array of hashes of supported\_documents for each country

## supported\_documents\_for\_country

Returns the supported\_documents\_list for the country

## is\_country\_supported

Returns 1 if country supported and 0 for unsupported

## sdk\_token

Returns the generated Onfido Web SDK token for the applicant.

[https://documentation.onfido.com/#web-sdk-tokens](https://documentation.onfido.com/#web-sdk-tokens)

Takes the following named parameters:

- `applicant_id` - ID of the applicant to request the token for
- `referrer` - the URL of the web page where the Web SDK will be used

## endpoints

Returns an accessor for the endpoints data. This is a hashref containing URI
templates, used by ["endpoint"](#endpoint).

## endpoint

Expands the selected URI via [URI::Template](https://metacpan.org/pod/URI%3A%3ATemplate). Each item is defined in our `endpoints.json`
file.

Returns a [URI](https://metacpan.org/pod/URI) instance.

## is\_rate\_limited

Returns true if we are currently rate limited, false otherwise.

May eventually be updated to return number of seconds that you need to wait.

## rate\_limiting

Applies rate limiting check.

Returns a [Future](https://metacpan.org/pod/Future) which will resolve once it's safe to send further requests.

# AUTHOR

deriv.com

# COPYRIGHT

Copyright Deriv.com 2019.

# LICENSE

Licensed under the same terms as Perl5 itself.
