#!/usr/bin/env python3
import os
import sys
from django.conf import settings
from django.core.wsgi import get_wsgi_application
from django.http import HttpResponse
from django.urls import path

# Django settings
settings.configure(
    DEBUG=os.environ.get('DJANGO_DEBUG', 'False').lower() == 'true',
    SECRET_KEY=os.environ.get('DJANGO_SECRET_KEY', 'fallback-dev-key-change-in-production'),
    ROOT_URLCONF=__name__,
    ALLOWED_HOSTS=os.environ.get('DJANGO_ALLOWED_HOSTS', 'localhost,127.0.0.1').split(','),
    MIDDLEWARE=[
        'django.middleware.security.SecurityMiddleware',
        'django.middleware.common.CommonMiddleware',
    ],
    # Security settings
    SECURE_BROWSER_XSS_FILTER=True,
    SECURE_CONTENT_TYPE_NOSNIFF=True,
    X_FRAME_OPTIONS='DENY',
)

def home(request):
    html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Django on AWS</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                text-align: center;
                margin: 50px;
                background-color: #f0f0f0;
            }
            .container {
                background-color: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                max-width: 600px;
                margin: 0 auto;
            }
            h1 {
                color: #333;
                margin-bottom: 20px;
            }
            p {
                color: #666;
                font-size: 18px;
                line-height: 1.6;
            }
            .success {
                color: #28a745;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🎉 Django Application Successfully Deployed!</h1>
            <p>Welcome to your Django application running on AWS EC2.</p>
            <p class="success">✅ VPC: noumantest</p>
            <p class="success">✅ Infrastructure deployed via Terraform</p>
            <p class="success">✅ Django server running on port 8000</p>
            <p>Your AWS infrastructure is now live and ready to use!</p>
        </div>
    </body>
    </html>
    '''
    return HttpResponse(html)

urlpatterns = [
    path('', home, name='home'),
]

application = get_wsgi_application()

if __name__ == '__main__':
    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)