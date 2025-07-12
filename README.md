# ZTI — Manifesto: A Free and Independent Distributed Network for Internet Threat Intelligence

# What is ZTI?
ZTI (Zero Trust Internet) is a community-driven, peer-to-peer (P2P) network dedicated to sharing real-time information about suspicious and malicious IP activity across the Internet.

Its mission is simple: empower individuals, organizations, and networks to protect themselves better — without depending on centralized, opaque, or commercial services.

# Our Principles

✅ Non-profit forever

ZTI is and will always remain a non-profit initiative. No paid memberships, no commercial services, no sponsors, no hidden fees. You will never be charged to participate or to access data.

✅ Independent and non-sponsored

ZTI operates entirely independently. It is not owned, sponsored, or controlled by any company, government, or commercial entity.

✅ Decentralized and federated

ZTI does not rely on a central server or authority. Nodes (participants) exchange data in a federated, peer-to-peer fashion. Each participant decides which nodes to trust and how to weigh their inputs.

✅ Privacy-respecting

All data shared across the network is anonymized at the source, using salted hashes or homomorphic systems. Raw IP addresses or personally identifiable information (PII) are never transmitted.

✅ Advisory, never mandatory

ZTI provides informative signals, not enforcement. Each participant is free to decide whether to use ZTI data purely for monitoring, to inform internal systems, or to integrate it into active defenses. ZTI holds no executive power over its participants.

How does it compare to existing systems?

Unlike other threat intelligence or crowd-based security systems:


Project: CrowdSec | Commercial ties: Yes (open core company) |  Centralization: Semi-centralized |  Agent required: Yes, own agent |  Open participation:  Limited by agent ecosystem

Project: AbuseIPDB | Commercial ties:	Yes (paid plans)	 |  Centralization:  Centralized |  Agent required: No |  Open participation: Requires API plan

Project: Spamhaus | Commercial ties: Yes (paid services)	 |  Centralization: Centralized |  Agent required: No |  Open participation: Access restricted or paid

Project: ZTI | Commercial ties: No, pure non-profit |  Centralization: Fully decentralized |  Agent required: No, system-agnostic |  Open participation:  Open to all, no fees

With ZTI:

Nobody will ever contact you to “onboard you for a fee.”

Nobody will ever sell access, datasets, or influence over the network.

Participation is voluntary, open, and designed to be for the common good, not for profit.

Why does it matter?

We live in an Internet where information about threats is often locked behind paywalls, controlled by corporations, or limited to specific software ecosystems.

ZTI believes security is a commons — it must be built and shared openly, ethically, and transparently.

Join us

If you are an individual, researcher, sysadmin, organization, or simply someone who wants to help make the Internet safer, ZTI invites you to join. Together, we can build a collaborative, privacy-respecting, and non-commercial foundation for global threat intelligence.


# Technical approach to ZeroTrustInternet
Zero Trust Internet (ZTI) is an initiative to address one of the root causes of today’s insecure internet

The internet has become a jungle shaped by the “Castle Syndrome”: defenders hide behind digital walls, waiting for attacks, while hackers, cybercriminals, and oppressive regimes relentlessly probe for cracks. Meanwhile, honest users suffer: protective measures often make their online life more difficult—sometimes exhausting user patience sooner than they deter attackers.

ZTI proposes a proactive approach. It offers a set of lightweight scripts that system administrators can integrate with existing defense tools (like Fail2ban or ddos-deflate) to generate informative JSON reports. These reports list attacking IP addresses and feed into interconnected databases. When an IP repeatedly engages in attacks or cybercrime, it is flagged for action across the network.

Before any ban, an information process is triggered: contacting the responsible ISP to determine whether the source is a hijacked zombie machine or a deliberately criminal system. Ideally, this leads to cleanup; if not, the ISP risks losing upstream connectivity.

ZTI envisions a global effort involving private actors (ISPs, datacenters) and international cybercrime authorities. The goal: an internet where safety is the default, not the exception—where going online is as safe as walking down a quiet street at night, and criminal activity is the rare outlier, not the background noise.

# EDNAC (Extended Distributed NAC)
EDNAC is a complementary, non-centralized Network Access Control system in which each node independently selects the sources of suspicious IP addresses it trusts or prefers to use. Rather than relying on a single centralized list, EDNAC enables distributed decision-making, allowing each participant to incorporate threat intelligence feeds or local detection mechanisms according to its own security policies and risk tolerance. Nodes can range from simple tables or IDS/IPS systems to complex AI-based threat
analyzers or ELK stacks.

# How it works

Each log-generating node involved in an Internet network—servers, routers, firewalls, etc.—can deliver a JSON report to remote nodes. This JSON can be anonymized for maximum privacy, using a salted hash that changes every X days (with salts shared across nodes) or more advanced homomorphic systems. Real ips are hidden using this mechanism.

Each receiving node interconnects with trusted sending nodes, identified by digital signatures. Nodes are free to select their trusted sources and assign weights—for example, giving more importance to data from Google Cloud compared to a specific university, or preferring sources within the same regional network (e.g., RedIRIS).

IP addresses reported by at least three independent sources within 24 hours are classified as dangerous. IP addresses reported for massive attacks by a single source are put into quarantine. These classifications are advisory: EDNAC does not enforce blocking. Each listener decides whether to integrate EDNAC as a reference (with or without executive power) or use it purely for consultative purposes. The scope of action is fully determined by the local user or system.


