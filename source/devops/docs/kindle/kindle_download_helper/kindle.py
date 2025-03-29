    def get_devices(self):
        """
        This method must be called before each download, so we ensure
        the session cookies before it is called
        """
        self.ensure_cookie_token()

        payload = {"param": {"GetDevices": {}}}
        r = self.session.post(
            self.urls["payload"],
            data={
                "data": json.dumps(payload),
                "csrfToken": self.csrf_token,
            },
        )
        r.raise_for_status()
        devices = r.json()
        if devices.get("error"):
            self.revoke_cookie_token(open_page=True)
            raise Exception(
                f"Error: {devices.get('error')}, please visit {self.urls['bookall']} to revoke the csrftoken and cookie"
            )
        devices = r.json()["GetDevices"]["devices"]
        ...
