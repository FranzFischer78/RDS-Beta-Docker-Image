# Raft Dedicated Servers (RDS) in Docker and Pterodactyl

This repository contains the necessary files to run a Raft Dedicated Server (RDS) in Docker and Pterodactyl.

## HOW TO USE
### Pterodactyl
1. Download the server egg...
2. Setup the server with the egg
3. Set the variables in the server settings (Steam username and password) (optional).
4. Go to the Files tab and upload the `RaftDedicatedServer.exe` you got from https://master.raftmodding.com/download to the server.
5. Start the server.
6. If all went smoothly you should see the server in the server list/be able to join the server using the join code.

### Docker
1. Pull the image:
`docker pull ghcr.io/franzfischer78/raftmodding-rds:latest`
2. Run the image:
```sh
docker run -e STARTUP=<startup_command> -e STEAM_USER=<your_steam_username> -e STEAM_PASS=<your_steam_password> -e STEAM_AUTH=<your_steam_auth_code> ghcr.io/franzfischer78/raftmodding-rds:latest 
```
or in Docker Desktop you can specify the environment variables in the GUI.

Note: It is optional to specify the Steam username and password. If you don't specify them you will have to enter them manually when the server starts or you just get the files another way.

3. Add the `RaftDedicatedServer.exe` you got from https://master.raftmodding.com/download to the server in `/home/container`.
4. Start the server.
5. If all went smoothly you should see the server in the server list/be able to join the server using the join code.

## Contributing

We welcome contributions! Please follow these steps to contribute:
1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and commit them with clear and concise messages.
4. Push your changes to your fork.
5. Create a pull request to the main repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, feel free to open an issue in the repository or contact me on the [raftmodding discord](https://www.raftmodding.com/discord).

If you want to support my work you can donate on kofi:
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/U7U1XZHXW)