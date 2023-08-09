#!/bin/bash

set -euo pipefail

LIB_CARD=
LIB_PIN=

PRISM_URL=https://

echo 'Logging in to get cookies/session'
curl $PRISM_URL/sessions -X POST -d "barcode=$LIB_CARD&institutionId=&pin=$LIB_PIN&borrowerLoginButton=Login" -c myLibraryCookies

sleep 1

echo 'Getting the list of books to renew'
BOOK_IDS=$(curl $PRISM_URL/account/loans -b myLibraryCookies -silent | grep loan_ids | sed -n '/.*/{ s/value="/%%%/;s/^.*%%%//; s/".*//; p; }' | sort -u)

sleep 1

echo 'Formatting that data into the post data format'
RENEW_DATA=$(echo $BOOK_IDS | sed -n 's/ /\&loan_ids%5B%5D=/g;p' | sed -n 's/^/loan_ids%5B%5D=/;p')

sleep 1

echo 'Renewing the books'
RENEW_RETURN=$(curl $PRISM_URL/account/loans -X POST -d "$RENEW_DATA" -b myLibraryCookies -silent)
RENEW_DATE=$(echo "$RENEW_RETURN" | grep -E '<td class="accDue">(\S*\s?\S*)\s*<\/td>' | sed -r 's/.*<td class="accDue">(\S*\s?\S*)\s*<\/td>/\1/')

sleep 1
echo Done!!

echo "Your Books are due on:"
echo "$RENEW_DATE" | sed 's/.*/- &/'