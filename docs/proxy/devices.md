# Proxy across your devices

Your Proxy can have a home on one computer while you use it from another
device. That home is the **host**: it stores your Life Map and conversations,
runs your agents, and connects to the models and tools you choose.

## Hosting and access

The native desktop host currently runs on macOS. Proxy Mobile runs on iOS.
Web chat and compatible connected apps can reach your Proxy from browsers on
other operating systems. Browser access does not require a native Proxy app
on that device.

| Surface | What you use it for |
| --- | --- |
| Desktop host | Set up agents, models, tools, and credentials; work with your Life Map, chats, and Moves |
| Proxy Mobile | Read conversations, work with agents, review Moves, and approve connections from your phone |
| Web chat | Chat through the web client configured for your Proxy address |
| Connected apps | Use the parts of your Proxy you have approved for that app |

[Request early access](https://theproxycompany.com/) for current app availability.
These surfaces have different capabilities; the desktop remains the setup
surface for local models, external agent runtimes, and tool credentials.

## On your phone

Proxy Mobile connects to your running host. It brings your Timeline, Roster,
Proxy chat, Moves, and Party conversations with you.

Use [your Proxy address](../proxy-ing/getting-started.md) and complete the
device approval flow. The app can accept an endpoint such as
`https://username.proxy.ing/mcp/proxy` and use the corresponding client API.

When a Move is ready, open it, review the prepared work, and choose **Yes**,
**No**, or **Later**. A connection request also appears as a Move, with who is
asking and what they want to access. Your approval belongs to you: an app's
connection token alone cannot make your Moves.

## In a browser or connected app

Your [Proxy address](../proxy-ing/index.md) routes supported web and app
requests to your host. A connected app asks for access, and you review the
request in Proxy. Giving someone your address does not give them your private
context.

Developers can follow [Connect your app](../proxy-ing/connect.md) to offer
that flow. The web client, native apps, and connected apps do not all expose
the same controls.

## Keep the host connected

Remote work depends on a reachable host. If it is asleep, offline, or Proxy is
closed, your phone or app may be unable to load current information or run
work. Check the host and its connection before retrying. A cached mobile view
is not proof that new work has reached the host.

Your Life Map stays on your host. Using a cloud model or connected service
still sends the information needed for that request to that provider.
