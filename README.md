# ZeroTrustInternet
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


