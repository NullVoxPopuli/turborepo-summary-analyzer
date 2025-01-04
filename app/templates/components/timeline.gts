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
  get timelineData() {
    return this.args.tasks.map((task) => {
      return {
        task: task.taskId,
        // group: task.task,
        group: task.package,
        startDate: task.execution.startTime,
        endDate: task.execution.endTime,
        description: task.package,
      };
    });
  }

  @cached
  get groups() {
    return [...new Set([...this.timelineData.map((x) => x.group)])];
  }

  @cached
  get byDate() {
    return this.timelineData.sort((a, b) =>
      d3.ascending(a.startDate, b.startDate)
    );
  }

  @cached
  get byGroup() {
    return d3
      .groups(this.timelineData, (d) => d.group)
      .sort((a, b) => d3.ascending(a[1].startDate, b[1].startDate));
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
    let box = element.getBoundingClientRect();
    const plot = Plot.plot({
      marks: [
        Plot.frame({ stroke: settings.panelBorder == 'show' ? '#aaa' : null }),
        Plot.barX(this.timelineData, {
          y: 'task',
          x1: (d) => parser(d.startDate),
          x2: (d) => parser(d.endDate),
          fill: 'group',
          rx: settings.barRoundness,
          insetTop: settings.barHeight,
          insetBottom: settings.barHeight,
        }),
        Plot.text(this.timelineData, {
          y: 'task',
          x: (d) => parser(d.startDate),
          text: (d) => d.task,
          textAnchor: 'start',
          dy: settings.textPosition,
          fontSize: settings.fontSize,
          stroke: 'white',
          fill: 'dimgray',
          fontWeight: 500,
        }),
        Plot.tip(
          this.timelineData,
          Plot.pointerY({
            y: 'task',
            x1: (d) => parser(d.startDate),
            x2: (d) => parser(d.endDate),
            title: (d) =>
              `Team: ${d.group}\nTask: ${d.task}\nDescription: ${d.description}\nStart: ${d.startDate}\nEnd: ${d.endDate}`,
          })
        ),
      ],
      height: box.height,
      width: box.width,
      x: {
        grid: true,
      },
      y: {
        domain: this.byDate,
        label: null,
        tickFormat: null,
        grid: false,
      },
      color: { domain: this.byGroup, range: this.colors, legend: false },
    });

    element.append(plot);
  });

  <template>
    {{log this.timelineData}}
    <div style="width: 100%; height: 200px;" {{this.chart}}></div>
  </template>
}
