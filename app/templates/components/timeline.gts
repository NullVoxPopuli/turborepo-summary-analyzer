import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import type { SummaryTask } from 'turborepo-summary-analyzer/types';
import * as Plot from '@observablehq/plot';
import * as d3 from 'd3';
import { modifier } from 'ember-modifier';

// https://d3js.org/d3-time-format
const parser = d3.utcParse('%Q');
const settings = {
  barRoundness: 0,
  panelBorder: 'hide',
  barHeight: 12,
  textPosition: 0,
  fontSize: 14,
};

/**
 * https://observablehq.com/@observablehq/build-your-own-gantt-chart
 */
export class Timeline extends Component<{
  Args: {
    tasks: SummaryTask[];
  };
}> {
  @cached
  get byId() {
    return d3.index(this.args.tasks, (d) => d.taskId);
  }

  @cached
  get groups() {
    return [...new Set([...this.args.tasks.map((x) => x.package)])];
  }

  @cached
  get byDate() {
    return this.args.tasks.sort((a, b) =>
      d3.ascending(a.execution.startTime, b.execution.startTime)
    );
  }

  @cached
  get colors() {
    return this.groups.map((group) => {
      return {
        group,
        color: 'red',
      };
    });
  }

  chart = modifier((element) => {
    const box = element.getBoundingClientRect();
    const plot = Plot.plot({
      height: box.height,
      width: box.width,
      color: {
        type: 'linear',
        range: ['blue', 'orange'],
        interpolate: 'hcl',
      },
      x: {
        grid: true,
        type: 'utc',
        ticks: 20,
      },
      y: {
        grid: false,
        // tickFormat: (t) => this.byId.get(t)?.taskId,
        tickFormat: null,
        axis: 'left',
        label: null,
      },
      // color: { domain: this.byGroup, range: this.colors, legend: false },
      marks: [
        Plot.barX(this.args.tasks, {
          fill: (d) => this.groups.indexOf(d.package),
          stroke: (d) => this.groups.indexOf(d.package),
          fillOpacity: 0.6,
          // strokeOpacity: 0.7,
          x1: (d) => d.execution.startTime,
          x2: (d) => d.execution.endTime,
          y: (d) => d.taskId,
          title: (d) => `${d.package} >> ${d.task}`,
        }),
      ],
    });

    element.append(plot);
  });

  <template>
    {{log @tasks}}
    <div style="width: 100%; height: 50dvh;" {{this.chart}}></div>
  </template>
}
