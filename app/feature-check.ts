import type Owner from '@ember/owner';
import { getOwner } from '@ember/owner';

const features = {
  'Intl.DurationFormat': 'DurationFormat' in Intl,
};

export const missingFeatures = Object.entries(features)
  .map(([name, isSupported]) => (isSupported ? null : name))
  .filter(Boolean) as string[];

export function checkFeatures(context: object) {
  const owner = getOwner(context) as Owner;
  const router = owner.lookup('service:router');

  if (missingFeatures.length > 0) {
    router.transitionTo(`missing-features`);
    return true;
  }
  return false;
}
