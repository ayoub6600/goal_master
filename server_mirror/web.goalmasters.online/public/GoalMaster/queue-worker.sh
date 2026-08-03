
#!/bin/bash
php /home/u644578691/domains/goalmasters.online/public_html artisan queue:work --timeout=60 --tries=3
