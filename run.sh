#! /bin/bash

# FONT COLOR
RED=='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

CURRENTDIR=$(dirname "$0")
DOMAIN_LIST="$CURRENTDIR""/domain.lst"
SECRET_FILE="$CURRENTDIR""/secret.key"
CURRENT_IP=$(curl -s ip.me)
BASEURL="https://api.cloudflare.com/client/v4/zones/"
APITOKEN=`egrep "^APITOKEN" "$SECRET_FILE"| awk -F "=" '{print $2}'`
ZONEID=`egrep "^ZONEID" "$SECRET_FILE"| awk -F "=" '{print $2}'`
CONTENT_TYPE="Content-Type:application/json"
AUTH="Authorization: Bearer "

get_zoneid(){
    #input  : base domain
    #output : zoneid
    #example: get_zoneid "domain.com"
    curl -s "$BASEURL""?name=""$1" -H "$CONTENT_TYPE" -H "$AUTH$APITOKEN" | jq -r '.result|.[0]|.id'
}

get_recordid(){
    #input  : subdomain
    #output : recordid
    #example: get_recordid "home.domain.com"
    curl -s "$BASEURL""$ZONEID""/dns_records?type=A&name=""$1" -H "$CONTENT_TYPE" \
         -H "$AUTH$APITOKEN" | jq -r '.result|.[0]|.id'
}

get_arecordip(){
    #input  : recordid
    #output : ip
    #example: get_arecordip "abc123def456"
    curl -s "$BASEURL""$ZONEID""/dns_records/""$1" -H "$CONTENT_TYPE" \
         -H "$AUTH$APITOKEN" | jq -r '.result.content'
}

update_arecordip(){
    #input  : recordid, subdomain, newip, proxy(true/false)
    #output : true/false
    #example: update_arecordip "abc123def456" "home.domain.com" "1.2.3.4" true
    status=$(curl -s -X PUT "$BASEURL""$ZONEID""/dns_records/""$1" -H "$CONTENT_TYPE" -H "$AUTH$APITOKEN" \
            -d '{"type":"A","name":"'"$2"'","content":"'"$3"'","ttl":1,"proxied":'$4'}'| jq .success)
    echo -n "$2 : "
    [ "$status" == "true" ] && echo -e "${GREEN}success${NC}" || echo -e "${RED}failed${NC}"
}

if [[ $1 == "-all" ]]
then
    tempfile=$(mktemp)
    curl -s "$BASEURL""$ZONEID""/dns_records/?type=A" -H "$CONTENT_TYPE" \
            -H "$AUTH$APITOKEN" | jq -jr '.result|.[]|.id," ",.name,"\n"' > "$tempfile"
    while IFS=" " read -r recordid domain
    do
        update_arecordip "$recordid" "$domain" "$CURRENT_IP" true
    done < "$tempfile"
else
    while IFS=' ' read -r domain proxy
    do
        RECORDID=$(get_recordid $domain)
        update_arecordip "$RECORDID" "$domain" "$CURRENT_IP" "$proxy"
    done < "$DOMAIN_LIST"
fi
