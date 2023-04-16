# kkFileView
文档在线预览项目解决方案，项目使用流行的spring boot搭建，易上手和部署。万能的文件预览开源项目，基本支持主流文档格式预览，如：
1. 支持 doc, docx, xls, xlsx, xlsm, ppt, pptx, csv, tsv, dotm, xlt, xltm, dot, dotx,xlam, xla 等 Office 办公文档
2. 支持 wps, dps, et, ett, wpt 等国产 WPS Office 办公文档
3. 支持 odt, ods, ots, odp, otp, six, ott, fodt, fods 等OpenOffice、LibreOffice 办公文档
4. 支持 vsd, vsdx 等 Visio 流程图文件
5. 支持 wmf, emf 等 Windows 系统图像文件
6. 支持 psd 等 Photoshop 软件模型文件
7. 支持 pdf ,ofd, rtf 等文档
8. 支持 xmind 软件模型文件
9. 支持 bpmn 工作流文件
9. 支持 eml 邮件文件
10. 支持 epub 图书文档
10. 支持 obj, 3ds, stl, ply, gltf, glb, off, 3dm, fbx, dae, wrl, 3mf, ifc, brep, step, iges, fcstd, bim 等 3D 模型文件
11. 支持 dwg, dxf 等 CAD 模型文件
12. 支持 txt, xml(渲染), md(渲染), java, php, py, js, css 等所有纯文本
13. 支持 zip, rar, jar, tar, gzip, 7z 等压缩包
14. 支持 jpg, jpeg, png, gif, bmp, ico, jfif, webp 等图片预览（翻转，缩放，镜像）
15. 支持 tif, tiff 图信息模型文件
16. 支持 tga 图像格式文件
17. 支持 svg 矢量图像格式文件
18. 支持 mp3,wav,mp4,flv 等音视频格式文件
19. 支持 avi,mov,rm,webm,ts,rm,mkv,mpeg,ogg,mpg,rmvb,wmv,3gp,ts,swf 等视频格式转码预览

# 部署
## 打包
```sh
mvn clean package -DskipTests -Prelease
```
## 生成镜像
```sh
docker build -t kkfileview .
```
## 发布镜像到私有仓库
```sh
docker login your_repo
docker tag kkfileview your_repo/kkfileview:4.2.0
docker push your_repo/kkfileview:4.2.0
```
## 结合项目使用
### kkfileview容器
```yaml
version: '3'
services:
    kkfileview:
        restart: always
        image: your_repo/kkfileview:4.2.0
        containner_name: kkfileview
        volumes:
        - /www/kkfileview/file:/opt/kkFileView-4.2.0/file
        - /www/kkfileview/logs:/opt/kkFileView-4.2.0/logs
        environment:
        # office文件类型首选pdf格式预览
        - KK_OFFICE_PREVIEW_TYPE=pdf
```
### nginx转发
```nginx
# 假设的业务系统
upstream system {
    server 127.0.0.1:7001;
}

# kkfileview服务
upstream kkfileview {
    server 127.0.0.1:8012;
}

server {
    # 只写了需要配置的内容，其他可自行补充

    # 网站图标
    location = /preview/favicon.ico {
        rewrite .* /favicon.ico;
    }

    # 预览接口
    location ~* '^/preview/([0-9a-f]{24})([\/0-9a-z_]*\.[a-z]+)?$' {
        # 权限验证
        set $fileid $1;
        set $other $2;
        auth_request @previewauth;

        # 预览文件
        set $proxyuri onlinePreview;
        if ($other ~* ^.+$) {
            set $proxyuri $fileid$other;
        }
        if ($args ~* ^.+$) {
            set $proxyuri $proxyuri?$args;
        }
        proxy_set_header X-Base-Url $scheme://$host:$server_port/preview;
        proxy_pass http://kkfileview/$proxyuri;
    }

    # 特殊接口
    location ~* ^/preview/(onlinePreview|getCorsFile)$ {
        # 权限验证
        set $proxyuri $1?$args;
        set $fileurl $arg_url;
        if ($arg_urlPath ~* ^.+$) {
            set $fileurl $arg_urlPath;
        }
        auth_request @previewauth;

        # 预览文件
        proxy_set_header X-Base-Url $scheme://$host:$server_port/preview;
        proxy_pass http://kkfileview/$proxyuri;
    }

    # 静态资源
    location ~* '^/preview/([^/\d]{2,15}\/.+)$' {
        proxy_set_header X-Base-Url $scheme://$host:$server_port/preview;
        proxy_pass http://kkfileview/$1?$args;
    }

    # 权限验证
    location @previewauth {
        internal;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # 鉴权接口，需要支持id跟url鉴权
        proxy_pass http://system/api/preview/auth?id=$fileid&url=$fileurl;
    }
}
```