import { sortBy } from '../../common/collections';
import { useBackend } from '../backend';
import { BlockQuote, Box, Button, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type GeneralInfo = {
  owner: string;
  page: string;
  possible_races: string[];
  IRC_data: IRCData | null;
};

type IRCData = {
  name: string;
  ID: number;
  currentStage: number;
}


export const IRCCustomizer = (props, context) => {
  const { act } = useBackend(context);
  const { data } = useBackend<GeneralInfo>(context);
  if(data.page == "General") {
    return (
      <Window width={560} height={420}>
        <Window.Content scrollable>
          <Section
            title = 'IRC-кастомизатор'
            buttons={(
              <Button
                icon = 'lock'
                content = 'Очистить и выйти'
                color = 'bad'
                onClick={() => act('erase-all')}
                />
            )}
            >
            <LabeledList>
              <LabeledList.Item
                label="Владелец"
                color='good'
                >
                {data.owner}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Window.Content>
      </Window>
    );
  }
  if(data.page == "Customization") {
    switch(data.IRC_data.currentStage) {
      case 1: {
        let JSON_output: string
        let chosen_race: string = data.possible_races[0]
        return (
          <Window width={560} height={420}>
            <Window.Content scrollable>
            <DefaultCustomisationSection></DefaultCustomisationSection>
            <Section
              title = 'Стадия I'
              >
              <BlockQuote>
                Выберите вид синтетика, к которому будет принадлежать КРБ.
              </BlockQuote>
              {data.possible_races.map(race => (
                <Button
                  fluid
                  key={race}
                  content={race}
                  textAlign="center"
                  selected={chosen_race === race}
                  onClick={() => {
                    chosen_race = race
                  }} />
              ))}
              <Button
                  fluid
                  key="end_stage"
                  content="Завершить стадию"
                  textAlign="center"
                  onClick={() => {
                    const output = {
                      stage: "1",
                      choices: {
                        chosen_race: chosen_race
                      }
                    }
                    JSON_output = JSON.stringify(output)
                    act("handle_JSON", {JSON: JSON_output})
                  }} />
            </Section>
            </Window.Content>
          </Window>
        );
      }
      case 2: {

      }
    }
  }
};

export const DefaultCustomisationSection = (props, context) => {
  const { act } = useBackend(context);
  const { data } = useBackend<GeneralInfo>(context);
  return (
    <Section
      title = 'IRC-кастомизатор'
      buttons={(
        <Button
          icon = 'lock'
          content = 'Очистить и выйти'
          color = 'bad'
          onClick={() => act('erase-all')}
          />
      )}
      >
      <LabeledList>
      <LabeledList.Item
          label="Оператор"
          color='average'
          >
          {data.owner}
        </LabeledList.Item>
        <LabeledList.Item
          label="Наименование КРБ"
          color='good'
          >
          {data.IRC_data.name}
        </LabeledList.Item>
        <LabeledList.Item
          label="Серийный номер"
          color='good'
          >
          {data.IRC_data.ID}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  )
}
