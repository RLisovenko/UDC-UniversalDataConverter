 собираем  из контейнер p1-2_UDC_web>   - docker build -f docker\WEB_UDC\Dockerfile -t web_udc .
 для Basch 				- docker build -f docker/WEB_UDC/Dockerfile -t web_udc .

собираем из docker\WEB_UDC\Dockerfile  - docker build -f Dockerfile -t web_udc ..\..

docker build -t web_udc:latest -f web_udc/Dockerfile 
-f web_udc/Dockerfile   → где лежит Dockerfile
..                      → build context = весь p1-2_UDC_web

docker compose up -d --force-recreate web_udc пересоздаёт контейнер с новым web_udc