import time
import json
import copy
import uuid
import base64
import os
from locust import HttpUser, task, between

class AidboxUser(HttpUser):
    def on_start(self):
      self.client_id = os.getenv("CLIENT_ID")
      self.client_secret = os.getenv("CLIENT_SECRET")
      self.token_url = os.getenv("KEYCLOAK_URL") + "/auth/realms/pkb/protocol/openid-connect/token"
      self.appt_ids = []
      self.token = None
      self.expiry = None
      self.get_token()

    @task
    def putAppointment(self):
        appointment = copy.deepcopy(appointment_template)
        id = str(uuid.uuid4())
        appointment["id"] = id
        self.client.put("/fhir/Appointment/" + id, headers={"authorization": "Bearer " + self.get_token()}, json=appointment, name="/fhir/Appointment/[id]")
        self.appt_ids.append(id)

    @task
    def getAppointment(self):
        xx = int(time.time())
        if len(self.appt_ids) > 0:
          id = self.appt_ids[xx % len(self.appt_ids)]
        else:
          id = "foo"
        self.client.get("/fhir/Appointment/" + id, headers={"authorization": "Bearer " + self.get_token(), "accept": "application/json"}, name="/fhir/Appointment/[id]")

    def get_token(self):
        if (self.expiry is None) or (self.expiry - time.time() < 15):
            resp = self.client.post(self.token_url, data={
                "grant_type": "client_credentials",
                "client_id": self.client_id,
                "client_secret": self.client_secret
            })
            new_token = resp.json()["access_token"]
            tokenSplit = new_token.split(".")
            # yuck https://stackoverflow.com/questions/2941995/python-ignore-incorrect-padding-error-when-base64-decoding
            tokenPt1Str = base64.b64decode(tokenSplit[1] + "==").decode("utf-8")
            tokenPt1O = json.loads(tokenPt1Str)
            self.expiry = tokenPt1O['exp']
            self.token = new_token
        return self.token

appointment_template = json.loads("""
{
  "resourceType": "Appointment",
  "id": "example",
  "status": "booked",
  "serviceCategory": [
    {
      "coding": [
        {
          "system": "http://example.org/service-category",
          "code": "gp",
          "display": "General Practice"
        }
      ]
    }
  ],
  "serviceType": [
    {
      "coding": [
        {
          "code": "52",
          "display": "General Discussion"
        }
      ]
    }
  ],
  "specialty": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "394814009",
          "display": "General practice"
        }
      ]
    }
  ],
  "appointmentType": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/v2-0276",
        "code": "FOLLOWUP",
        "display": "A follow up visit from a previous appointment"
      }
    ]
  },
  "priority": 5,
  "description": "Discussion on the results of your recent MRI",
  "start": "2013-12-10T09:00:00Z",
  "end": "2013-12-10T11:00:00Z",
  "created": "2013-10-10",
  "comment": "Further expand on the results of the MRI and determine the next actions that may be appropriate.",
  "participant": [
    {
      "actor": {
        "display": "Peter James Chalmers"
      },
      "required": "required",
      "status": "accepted"
    },
    {
      "type": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/v3-ParticipationType",
              "code": "ATND"
            }
          ]
        }
      ],
      "actor": {
        "display": "Dr Adam Careful"
      },
      "required": "required",
      "status": "accepted"
    },
    {
      "actor": {
        "display": "South Wing, second floor"
      },
      "required": "required",
      "status": "accepted"
    }
  ]
}
""")