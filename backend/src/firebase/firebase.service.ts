import { Injectable, OnModuleInit } from '@nestjs/common';

import {
  App,
  cert,
  getApps,
  initializeApp,
  ServiceAccount,
} from 'firebase-admin/app';

import { getMessaging } from 'firebase-admin/messaging';

import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private app!: App;

  onModuleInit() {
    const serviceAccountPath = path.join(
      process.cwd(),
      'firebase-service-account.json',
    );

    const serviceAccount = JSON.parse(
      fs.readFileSync(serviceAccountPath, 'utf8'),
    ) as ServiceAccount;

    const existingApps = getApps();

    if (existingApps.length === 0) {
      this.app = initializeApp({
        credential: cert(serviceAccount),
      });
    } else {
      this.app = existingApps[0];
    }
  }

  async sendNotification({
    token,
    title,
    body,
  }: {
    token: string;
    title: string;
    body: string;
  }) {
    return getMessaging(this.app).send({
      token,

      notification: {
        title,
        body,
      },

      android: {
        priority: 'high',
        notification: {
          sound: 'default',
        },
      },

      webpush: {
        headers: {
          Urgency: 'high',
        },

        notification: {
          title,
          body,
          icon: 'https://farmpilot-646c1.web.app/icons/Icon-192.png',
          badge: 'https://farmpilot-646c1.web.app/icons/Icon-192.png',
        },

        fcmOptions: {
          link: 'https://farmpilot-646c1.web.app',
        },
      },
    });
  }
}