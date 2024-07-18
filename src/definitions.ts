export interface AudioPlayerPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
