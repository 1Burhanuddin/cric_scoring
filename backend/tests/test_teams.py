import uuid

from .test_auth import _sign_in


def _auth(client, phone):
    session = _sign_in(client, phone)
    return {"Authorization": f"Bearer {session['access_token']}"}, session["user"]["id"]


def _new_team_id() -> str:
    return uuid.uuid4().hex


def _create_team(client, headers, name, user_id, city=None):
    team_id = _new_team_id()
    response = client.put(
        f"/teams/{team_id}",
        json={
            "name": name,
            "city": city,
            "team_players": [{"id": user_id, "role": "admin"}],
        },
        headers=headers,
    )
    assert response.status_code == 200, response.text
    return response.json()


def test_upsert_creates_team_with_given_id_and_players(client):
    headers, user_id = _auth(client, "5000000001")

    body = _create_team(client, headers, "Mumbai Strikers", user_id, city="Mumbai")
    assert body["name"] == "Mumbai Strikers"
    assert body["name_lowercase"] == "mumbai strikers"
    assert len(body["team_players"]) == 1
    assert body["team_players"][0]["id"] == user_id
    assert body["team_players"][0]["role"] == "admin"


def test_upsert_on_existing_team_replaces_roster_and_requires_admin(client):
    admin_headers, admin_id = _auth(client, "5000000008")
    other_headers, _ = _auth(client, "5000000009")

    team_id = _new_team_id()
    client.put(
        f"/teams/{team_id}",
        json={"name": "Pune Panthers", "team_players": [{"id": admin_id, "role": "admin"}]},
        headers=admin_headers,
    )

    forbidden = client.put(
        f"/teams/{team_id}",
        json={"name": "Hijacked FC", "team_players": [{"id": admin_id, "role": "admin"}]},
        headers=other_headers,
    )
    assert forbidden.status_code == 403

    updated = client.put(
        f"/teams/{team_id}",
        json={"name": "Pune Panthers Renamed", "team_players": [{"id": admin_id, "role": "admin"}]},
        headers=admin_headers,
    )
    assert updated.status_code == 200
    assert updated.json()["name"] == "Pune Panthers Renamed"
    assert len(updated.json()["team_players"]) == 1


def test_team_stat_defaults_to_zero(client):
    headers, user_id = _auth(client, "5000000002")
    team_id = _create_team(client, headers, "Zero Stat FC", user_id)["id"]

    response = client.get(f"/teams/{team_id}/stat")
    assert response.status_code == 200
    body = response.json()
    assert body["played"] == 0
    assert body["status"] == {"win": 0, "tie": 0, "lost": 0}


def test_team_name_availability(client):
    headers, user_id = _auth(client, "5000000003")
    _create_team(client, headers, "Unique Eagles", user_id)

    taken = client.get("/teams/name-available", params={"name": "Unique Eagles"})
    assert taken.status_code == 200
    assert taken.json() is False

    free = client.get("/teams/name-available", params={"name": "Totally New Name"})
    assert free.json() is True


def test_add_and_remove_players_requires_admin(client):
    admin_headers, admin_id = _auth(client, "5000000004")
    player_headers, player_id = _auth(client, "5000000005")

    team_id = _create_team(client, admin_headers, "Delhi Dynamos", admin_id)["id"]

    add_response = client.post(
        f"/teams/{team_id}/players",
        json={"players": [{"id": player_id, "role": "player"}]},
        headers=admin_headers,
    )
    assert add_response.status_code == 200
    assert len(add_response.json()["team_players"]) == 2

    forbidden_remove = client.request(
        "DELETE",
        f"/teams/{team_id}/players",
        json={"players": [{"id": player_id, "role": "player"}]},
        headers=player_headers,
    )
    assert forbidden_remove.status_code == 403

    remove_response = client.request(
        "DELETE",
        f"/teams/{team_id}/players",
        json={"players": [{"id": player_id, "role": "player"}]},
        headers=admin_headers,
    )
    assert remove_response.status_code == 200
    assert len(remove_response.json()["team_players"]) == 1


def test_get_teams_by_member(client):
    headers, user_id = _auth(client, "5000000010")
    _create_team(client, headers, "Bengaluru Blasters", user_id)

    response = client.get(f"/teams/by-member/{user_id}")
    assert response.status_code == 200
    assert any(t["name"] == "Bengaluru Blasters" for t in response.json())


def test_delete_team_requires_admin(client):
    admin_headers, admin_id = _auth(client, "5000000006")
    other_headers, _ = _auth(client, "5000000007")

    team_id = _create_team(client, admin_headers, "Chennai Chargers", admin_id)["id"]

    forbidden = client.delete(f"/teams/{team_id}", headers=other_headers)
    assert forbidden.status_code == 403

    ok = client.delete(f"/teams/{team_id}", headers=admin_headers)
    assert ok.status_code == 204
