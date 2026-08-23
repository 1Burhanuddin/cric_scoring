from .test_auth import _sign_in


def test_update_me(client):
    token = _sign_in(client, "6000000001")["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    response = client.patch(
        "/users/me",
        json={"name": "Updated Name", "location": "Mumbai"},
        headers=headers,
    )
    assert response.status_code == 200
    body = response.json()
    assert body["name"] == "Updated Name"
    assert body["name_lowercase"] == "updated name"
    assert body["location"] == "Mumbai"


def test_get_users_by_ids(client):
    session = _sign_in(client, "6000000002")
    user_id = session["user"]["id"]

    response = client.get("/users", params={"ids": [user_id]})
    assert response.status_code == 200
    assert response.json()[0]["id"] == user_id


def test_get_user_not_found(client):
    response = client.get("/users/does-not-exist")
    assert response.status_code == 404
    assert response.json()["error_code"] == "user-not-found"


def test_search_users_by_name(client):
    _sign_in(client, "6000000003", name="Zebra Player")

    response = client.get("/users/search/by-name", params={"q": "zebra"})
    assert response.status_code == 200
    assert any(u["name"] == "Zebra Player" for u in response.json())


def test_upsert_and_fetch_user_stats(client):
    user_id = _sign_in(client, "6000000004")["user"]["id"]

    upsert_response = client.put(
        f"/users/{user_id}/stats",
        json={
            "matches": 5,
            "type": "test",
            "batting": {"run_scored": 120},
            "bowling": {},
            "fielding": {},
        },
    )
    assert upsert_response.status_code == 200
    assert upsert_response.json()["matches"] == 5

    list_response = client.get(f"/users/{user_id}/stats")
    assert list_response.status_code == 200
    assert list_response.json()[0]["batting"]["run_scored"] == 120
