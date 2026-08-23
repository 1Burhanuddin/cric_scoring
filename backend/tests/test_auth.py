def _sign_in(client, phone_number="7777777777", name="Auth User"):
    client.post("/auth/otp/send", json={"country_code": "+91", "phone_number": phone_number})
    response = client.post(
        "/auth/otp/verify",
        json={
            "country_code": "+91",
            "phone_number": phone_number,
            "otp": "000000",
            "device_id": "device-x",
            "device_name": "Pixel 8",
            "device_type": 2,
            "app_version": 1,
            "os_version": "14",
            "name": name,
        },
    )
    assert response.status_code == 200, response.text
    return response.json()


def test_otp_send_and_verify_creates_user_and_returns_token(client):
    send_response = client.post("/auth/otp/send", json={"country_code": "+91", "phone_number": "9999999999"})
    assert send_response.status_code == 204

    verify_response = client.post(
        "/auth/otp/verify",
        json={
            "country_code": "+91",
            "phone_number": "9999999999",
            "otp": "000000",
            "device_id": "device-1",
            "device_name": "Pixel 8",
            "device_type": 2,
            "app_version": 1,
            "os_version": "14",
            "name": "Test Player",
        },
    )
    assert verify_response.status_code == 200
    body = verify_response.json()
    assert body["access_token"]
    assert body["user"]["phone"] == "+91 9999999999"
    assert body["user"]["name"] == "Test Player"
    assert body["session"]["device_id"] == "device-1"


def test_otp_verify_rejects_wrong_code(client):
    client.post("/auth/otp/send", json={"country_code": "+91", "phone_number": "8888888888"})

    response = client.post(
        "/auth/otp/verify",
        json={
            "country_code": "+91",
            "phone_number": "8888888888",
            "otp": "111111",
            "device_id": "device-2",
            "device_name": "Pixel 8",
            "device_type": 2,
            "app_version": 1,
            "os_version": "14",
        },
    )
    assert response.status_code == 400
    assert response.json()["error_code"] == "invalid-verification-code"


def test_me_requires_auth(client):
    response = client.get("/users/me")
    assert response.status_code == 401
    assert response.json()["error_code"] == "unauthenticated"


def test_me_returns_current_user(client):
    token = _sign_in(client)["access_token"]
    response = client.get("/users/me", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["name"] == "Auth User"


def test_logout_invalidates_session(client):
    session = _sign_in(client, "6666666666")
    headers = {"Authorization": f"Bearer {session['access_token']}"}

    logout_response = client.post("/auth/logout", headers=headers)
    assert logout_response.status_code == 204

    me_response = client.get("/users/me", headers=headers)
    assert me_response.status_code == 401
    assert me_response.json()["error_code"] == "session-expired"
