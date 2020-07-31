# Cloudflare Dynamic IP

## Table of Contents 
- [Manual Setup](#manual-setup)
  * [Options](#options)
    + [Update all A records ( proxy on by default )](#update-all-a-records---proxy-on-by-default--)
- [Docker Setup](#docker-setup)

## Manual Setup
1. Install jq
```
sudo apt install -y jq
```
2. Clone this repo
```
git clone https://gitlab.com/finzzz/cf_dynamic_ip
```
3. Create Cloudflare API token
![](/images/api.png)
4. Get zoneid
   - go to https://dash.cloudflare.com/ and select domain you want to use
   - scroll down and see bottom right corner  
![](/images/zoneid.png)
5. Put API token and zoneid inside *secret.key* file
6. Put domain you want to modify inside *domain.lst*  
   ex1. test.domain.com true  
   ex2. test2.domain.com false  
   true means you want to use proxy  
   false will reveal your origin IP  
7. Make sure *secret.key* and *domain.lst* are in the same folder as *run.sh*

8. Make run.sh executable
```
sudo chmod +x run.sh  
```
9. Open crontab
```
crontab -e
```
10. Put this inside crontab, it will update your IP every 30 minutes.
```
*/30 * * * * /path/to/run.sh
```

### Options
#### Update all A records ( proxy on by default )
```
./run.sh -all
```
*This script will not use domain.lst file using this option*

## Docker Setup
1. Download docker-compose.yml
```
curl -O https://gitlab.com/finzzz/cf_dynamic_ip/-/raw/master/docker-compose.yml
```
2. Follow manual setup step 3-7
3. Adjust docker-compose.yml
4. Run the container
```
docker-compose up -d
```
5. **Optional** Run now
```
docker exec -it cf_dynamic_ip /cf_dynamic_ip/run.sh

# or
docker exec -it cf_dynamic_ip /cf_dynamic_ip/run.sh -all
```
