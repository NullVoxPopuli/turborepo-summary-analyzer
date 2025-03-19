import { Viewer } from './components/viewer.gts';
import { Viewer as View2 } from './components/viewer.gts';

import { DocumentDrop } from './components/document-drop';

<template>
  <Viewer />
  <View2 />
  {{x}}
  - ^ deliberately undefined
  <DocumentDrop />
</template>
