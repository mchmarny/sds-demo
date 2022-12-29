package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestHelloAPIRoute(t *testing.T) {
	r := makeRouter()
	req, _ := http.NewRequest("GET", "/api/ping", nil)
	testResponse(t, r, req, testResponseStatusOK)
}

func testResponse(t *testing.T, r *gin.Engine, req *http.Request, f func(w *httptest.ResponseRecorder) bool) {
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if !f(w) {
		t.Fail()
	}
}

func testResponseStatusOK(w *httptest.ResponseRecorder) bool {
	return w.Code == http.StatusOK
}
