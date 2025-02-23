from __future__ import annotations

from django.http import HttpRequest, HttpResponse


def healthcheck(request: HttpRequest) -> HttpResponse:
    return HttpResponse("OK")
