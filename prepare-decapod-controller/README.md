# Prepare-decapod-controller Chart

This charts handle tasks for preparing decapod controllers. Currently, it only does one thing:
* Create postgresql secret that is used by both postgresql and argo-workflow chart.

The value 'postgres.secretName' is referenced by other charts as follows.
* values.existingSecret (by postgresql chart)
* values.persistence.userNameSecret & values.persistence.passwordSecret (by argo-workflows chart)

More preparation tasks can be added to this chart later.

