# multibox_box

Terraform module to provision a box within multibox and configure access control with keycloak.
Provisions: 
* the box in a multibox server
* a client in keycloak to represent the box
* client-specific roles in keycloak for different levels of access to the box
* policies in the multibox for those roles to access some APIs
* bearer token verification in aidbox

This module is shared between our e2e testing and sandbox/production deployments.