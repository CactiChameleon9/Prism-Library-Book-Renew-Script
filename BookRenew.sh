#!/bin/bash

LIB_CARD=
LIB_PIN=

PRISM_URL=https://

# get cookies/session
curl $PRISM_URL/sessions -X POST -d "barcode=$LIB_CARD&institutionId=&pin=$LIB_PIN&borrowerLoginButton=Login" -c myLibraryCookies

# get books to renew
BOOK_IDS=$(curl $PRISM_URL/account/loans -b myLibraryCookies -silent | grep loan_ids | sed -n '/.*/{ s/value="/%%%/;s/^.*%%%//; s/".*//; p; }' | sort -u)

# put in the post data format
RENEW_DATA=$(echo $BOOK_IDS | sed -n 's/ /\&loan_ids%5B%5D=/g;p' | sed -n 's/^/loan_ids%5B%5D=/;p')

# get renew books
curl $PRISM_URL/account/loans -X POST -d "$RENEW_DATA" -b myLibraryCookies -silent
