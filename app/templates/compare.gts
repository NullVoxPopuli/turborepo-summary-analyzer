import { pageTitle } from 'ember-page-title';
import { JsonCompare } from './components/json-compare';

<template>
  {{pageTitle "Compare"}}
  <h2>JSON Diff</h2>
  <JsonCompare />
</template>
