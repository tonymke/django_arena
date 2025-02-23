from __future__ import annotations

from django.http import HttpRequest, HttpResponse
from django.shortcuts import render


def index(request: HttpRequest) -> HttpResponse:
    return render(request, "core/index.html")


def healthcheck(request: HttpRequest) -> HttpResponse:
    return HttpResponse("OK")
