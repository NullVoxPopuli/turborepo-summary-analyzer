import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { tracked } from '@glimmer/tracking';
import { preventDefaults, handleDrop, handleFileChoose } from '../drop-utils';
import { readFileToJSON } from 'turborepo-summary-analyzer/utils';

interface FileState<T> {
  name?: string;
  data?: T;
  error?: string;
  dropping: boolean;
}

interface Args {
  onFileLoaded?: (fileState: FileState<unknown>) => void;
}

export default class JsonDropZone extends Component<Args> {
  @tracked fileState: FileState<unknown> = { dropping: false };

  get name() { return this.fileState.name; }
  get error() { return this.fileState.error; }
  get dropping() { return this.fileState.dropping; }

  async readFile(file: FileList[0]) {
    try {
      const result = await readFileToJSON(file);
      this.fileState = { ...this.fileState, name: result.name, data: result.json, error: undefined, dropping: false };
      this.args.onFileLoaded?.(this.fileState);
    } catch (e) {
      this.fileState = { ...this.fileState, error: 'Failed to parse JSON', dropping: false };
      this.args.onFileLoaded?.(this.fileState);
      console.error(e);
    }
  }

  onDragover = (e: DragEvent) => {
    preventDefaults(e);
    this.fileState = { ...this.fileState, dropping: true };
  };

  onDragleave = (e: DragEvent) => {
    preventDefaults(e);
    this.fileState = { ...this.fileState, dropping: false };
  };

  onDrop = async (e: DragEvent) => {
    preventDefaults(e);
    const file = handleDrop({ onError: (msg) => (this.fileState = { ...this.fileState, error: msg }) }, e);
    if (file) await this.readFile(file);
  };

  onFileChange = async (e: Event) => {
    const file = handleFileChoose({ onError: (msg) => (this.fileState = { ...this.fileState, error: msg }) }, e);
    if (file) await this.readFile(file);
  };


<template>
  <div class="pane" ...attributes>
    {{#if @title}}
      <h3>{{@title}}</h3>
    {{/if}}
    {{#if this.name}}
      <p class="filename">{{this.name}}</p>
      {{else}}
      <p class="filename">No file chosen</p>
    {{/if}}
    {{#if this.error}}<p class="error">{{this.error}}</p>{{/if}}
    <div class="drop-zone {{if this.dropping 'dropping'}}"
      {{on 'dragover' this.onDragover}}
      {{on 'dragleave' this.onDragleave}}
      {{on 'drop' this.onDrop}}>
      <p>Drop JSON here or <label class="file-choose">choose<input type="file" accept="application/json" hidden {{on 'change' this.onFileChange}} /></label></p>
    </div>
    <style>
      .drop-zone {
        cursor: pointer;
        border: 2px dashed #555;
        border-radius: .5rem;
        padding: .5rem;
        text-align: center;
        min-height: 4rem;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.2s, border-color 0.2s;
      }
      .drop-zone:hover {
        background: var(--drop-hover-bg, #333);
        border-color: var(--drop-hover-border, #888);
      }
      .drop-zone.dropping {
        background: var(--drop-bg, #222);
        border-color: var(--drop-active-border, #0af);
      }
    </style>
  </div>
</template>
}

